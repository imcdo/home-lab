let 
    ianDesktop = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJwCoP+9JDU6mH4pZCsk/GlhDXiarbdyaakIB1DzLMRtiv79U/aTkTvgm/TTmeQLM0W3vHYsKDloNRhRK87UbN798aiYk1g6w51OL7ClxlGStpZoRtTAA+enG2g55Vhx7WUM0kKvYw44iSWH60NN+XCItdHrGB6hBNf9Q86h+fzv2U92PvZOEjdX2PaNZ/2RR3QA6kf1ra8Na5RdXu3wvAZx+qAzrPXP8TGShcMc1kdYFC/RPzkUrj0Y2il3LXO7gAo1fi+RyZi9y0vvK3YNDHqxVE+dmMNYz9Ipsy2QBHF7vowJajvJVEAn8DQDSeQqRWwVeQZPTywzZbG8Ng0HlNV1QjUQbh3ZB3lWUdu5RQqD+Tltzo6fWkkN49FiYse/zlrIiUSayvALcGxeyvKTa0udIO2mGZO94aY/pg5uhG4/dHNk3JWRI2QyE0RyxCBRn9YksMPXVgkQ/ARgIbqrNP22JLFeffeB+zfBQQiPGsfnqTr8RWTyzlkltom6Uh5dksn7WfnbTofQbMIw6bU9x15+tmoxgJm3QzTnandpVXOsxSx5M2NJyTYIvkKegbJcRS0C4AiUeLDhm4feN/fg6oSRV4m+qpeFug0bO0AqjjKaaYOMHS6FoyT0osoLECMg0NjFdSuOVAdp7eB3sZD3nTtTPsnayyj+3uip+ajNhahw==";
    think = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOo0K5On6oJcpLHAPZbw8sgNaAoTfvYdX+VCuBSeLSAn";
    chromeA = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBt5IJzeVtLTnIq2b+08XqgFb+LqFhKF9A4J6wLS1NJE";
    chromeB = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMSQG5JO+REK6S0rT8h5pd2bDgYJyFWIfVxAJL9sjdQo";
in {
    "k3s-token.age".publicKeys = [
        ianDesktop
        think
        chromeA
        chromeB
    ];
}