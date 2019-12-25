{
  _config+:: {
    namespace: 'monitoring',
  },

  k3s: {
    master_ip: ['192.168.1.241'],
  },

  // Domain suffix for the ingresses
  suffixDomain: '192.168.1.241.nip.io',

  // Setting these to false, defaults to emptyDirs
  enablePersistence: {
    prometheus: false,
    grafana: false,
  },

  // Grafana "from" email
  grafana: {
    from_address: 'myemail@gmail.com',
  },
}
