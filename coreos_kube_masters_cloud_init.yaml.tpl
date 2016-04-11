#cloud-config

coreos:

  etcd2:
    proxy: on
    initial_cluster: ectd_elb=http://${ETCD_ELB_DNS_NAME}:2380
    listen-client-urls: http://0.0.0.0:2379

  flannel:
    etcd_endpoints: http://127.0.0.1:2379
    interface: $private_ipv4

  fleet:
    etcd-servers: http://127.0.0.1:2379
    metadata: etcd=proxy,kubernetes=master
    public-ip: $private_ipv4

  units:
    - name: etcd2.service
      command: start

    - name: fleet.service
      command: start

    - name: docker.service
      command: start
      drop-ins:
        - name: 40-flannel.conf
          content: |
            [Unit]
            Requires=flanneld.service
            After=flanneld.service

    - name: kubelet.service
      command: start
      content: |
${KUBE_KUBELET_MASTER_TEMPLATE_CONTENT}

    - name: flanneld.service
      command: start
      drop-ins:
        - name: 50-network-config.conf
          content: |
            [Unit]
            Requires=etcd2.service
            [Service]
            ExecStartPre=-/usr/bin/etcdctl mk /coreos.com/network/config "{\"Network\":\"10.2.0.0/16\"}"


write_files:
  - path: "/etc/kubernetes/manifests/kube-apiserver.yaml"
    permissions: "0644"
    content: |
      ${KUBE_APISERVER_TEMPLATE_CONTENT}

  - path: "/etc/kubernetes/manifests/kube-controller-manager.yaml"
    permissions: "0644"
    content: |
      ${KUBE_CONTROLLER_MANAGER_TEMPLATE_CONTENT}

  - path: "/etc/kubernetes/manifests/kube-podmaster.yaml"
    permissions: "0644"
    content: |
      ${KUBE_PODMASTER_TEMPLATE_CONTENT}

  - path: "/etc/kubernetes/manifests/kube-proxy.yaml"
    permissions: "0644"
    content: |
      ${KUBE_PROXY_TEMPLATE_CONTENT}

  - path: "/etc/kubernetes/manifests/kube-scheduler.yaml"
    permissions: "0644"
    content: |
      ${KUBE_SCHEDULER_TEMPLATE_CONTENT}

  - path: "/etc/kubernetes/manifests/kube-scheduler.yaml"
    permissions: "0644"
    content: |
      ${KUBE_SCHEDULER_TEMPLATE_CONTENT}
