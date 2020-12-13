[![Version][version-shield]][version]
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<br />

<h2 align="center">nginx-proxy-local-development</h3>
<p align="center">
    Easy management for SSL/TLS certificates and proxying local webservers for fast development setups!
    <br /><br />
    <a href="https://github.com/masfernandez/nginx-proxy-local-development/issues">Report Bug</a>
    ·
    <a href="https://github.com/masfernandez/nginx-proxy-local-development/issues">Request Feature</a>
</p>

<br />

<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>


## About The Project

I created this repository to speed up the initial configuration of local development environments, allowing the management of SSL/TLS certificates and local web servers.  

**Features**
- Multiple local webservers on different ports behind the reverse proxy server.
- Run local applications under SSL/TLS (for the development of a PWA with a serviceworker or Vue under SSL/TLS for example).
- 100% trusted certificates for browsers, curl and other applications.

In combination with services such as xip.io (What is xip.io? please read documentation here: [http://xip.io](http://xip.io)), allows also:

- No more /etc/hosts file editing
- Develop and test local applications from external hosts without complicated configurations
- Free alternative to Ngrok, Serveo, etc.



## Getting Started

The settings shown in this document are valid in a macOS environment, since the variable "host.docker.internal" is used to map the host's IP from the proxy container. This variable does not work on Windows or Linux. 

Expiration dates for included content:
- Certification Authority: October the 3rd, 2023 at 20:00:11 CEST
- Wildcard xip.io certificate: December the 13rd, 2021 at 19:22:47 CEST


### Prerequisites
 
- docker
- openssl (only for custom ca or certificates)
- composer (when used as a composer dependency, obviously)


### Installation

As standalone tool:
```
git clone github.com:masfernandez/nginx-proxy-local-development.git
```

As composer dependency:
```
composer req masfernandez/nginx-proxy-local-development
```


## Usage

Valid for reaching local webservers located at 127.0.0.1:&lt;any port&gt; (your computer) with an url domain like https://&lt;whatever&gt;.127.0.0.1.xip.io

Choose any subdomain on xip.io service for reach your great app (like backend.127.0.0.1.xip.io). 

In short, that subdomain will resolve to your local computer without editing /etc/hosts file. You can check it out now:

```
ping backend.127.0.0.1.xip.io
```

If you prefer using your custom SLD like my-cool-app.com instead &lt;whatever&gt;.xip.io, you can also use this repo to generate your own custom CA and certs. El principal inconveniente de esto es que tendrás que apuntar my-cool-app.com a la 127.0.0.1 IP editando el archivo /etc/hosts. Choosing this way I recommend using [Gas Mask](https://github.com/2ndalpha/gasmask).

### Fast usage as standalone tool

Configure Nginx vhost example located in docker/nginx/conf.d/backend.127.0.0.1.xip.io.conf as your needs.

That vhost example is using:
- Subdomain: backend.127.0.0.1.xip.io
- Local webserver running at 127:0.0.1:8080
- Nginx proxy from -> backend.127.0.0.1.xip.io to -> 127:0.0.1:8080

```
upstream backend {
    server host.docker.internal:8080; # <- override here the port your app is using
}

server {
    server_name backend.127.0.0.1.xip.io; # <- override here the subdomain your app is using
    listen 443 ssl http2 ;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:!DSS';
    ssl_prefer_server_ciphers on;
    ssl_session_timeout 5m;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;

    ssl_certificate /etc/nginx/certs/wildcard.127.0.0.1.xip.io.crt; # <- Check this out
    ssl_certificate_key /etc/nginx/certs/wildcard.127.0.0.1.xip.io.key; # <- Check this out
    ssl_client_certificate /etc/nginx/ca/masfernandez.crt; # <- Check this out

    add_header Strict-Transport-Security "max-age=31536000" always;

    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_redirect     off;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection "Upgrade";
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host $server_name;
    }
}
```

Build and run docker container:
```
docker-compose up -d
```

That's it! you can reach your local app at https://backend.127.0.0.1.xip.io.

Enjoy the development :)


### Fast usage as composer dependency

Create a docker-compose.yml file in the root of your project or integrate bellow service to your already current stack: 

```
  proxy:
    image: nginx:latest
    ports:
      - "443:443"
    volumes:
      - ./vendor/masfernandez/nginx-proxy-local-development/ca:/etc/nginx/ca:ro
      - ./vendor/masfernandez/nginx-proxy-local-development/certs/wildcard.127.0.0.1.xip.io:/etc/nginx/certs:ro
      - ./vendor/masfernandez/nginx-proxy-local-development/docker/nginx/conf.d:/etc/nginx/conf.d:ro
```

Show full example file:
```
cat vendor/masfernandez/nginx-proxy-local-development/docker-compose-example-proxy.yml
```

Build and run docker container
```
docker-compose up -d
```

That's it! you can reach your local app at https://backend.127.0.0.1.xip.io.

Enjoy the development :)


## Other configurations and customizations

If you want to generate your own CA, custom certificates or advanced configurations, please read bellow sections.

### Local webservers running in containers

When you are running the apps on local webservers under docker containers, there is already a great tool to act as a proxy and reach each service properly. Have a look at:

https://github.com/nginx-proxy/nginx-proxy

Also, you can use nginx-proxy/nginx-proxy in combination with masfernandez/nginx-proxy-local-development:

- nginx-proxy/nginx-proxy acting as a reverse proxy server to local webservers in docker
- masfernandez/nginx-proxy-local-development for generating custom trusted ssl/tls certs in development 


### Create and install your custom Certificate Authority

````
./gen-ca.sh
````

It will ask for sudo password to install on macOS keychain to avoid apps (browser, curl, etc.) 
complain that 'it's self-signed or has not been verified'

Firefox browser require manually installation.


### Generate single domain certificate

````
./gen-cert.sh <domain>.<IP>.xip.io
````

Examples:

````
./gen-cert.sh my-new-site.127.0.0.1.xip.io
./gen-cert.sh my-new-site.192.168.1.10.xip.io
````

If you prefer not using xip.io, still can generate your custom trusted certificates for local development:
````
./gen-cert.sh my-new-site.com
````


### Generate wildcard certificate

````
./gen-cert.sh wildcard.<IP>.xip.io
````

Examples:

````
./gen-cert.sh wildcard.127.0.0.1.xip.io
./gen-cert.sh wildcard.192.168.1.10.xip.io
````

If you prefer not using xip.io, still can generate your custom wildcard trusted certificates for local development:
````
./gen-cert.sh wildcard.my-new-site.com
````
Valid for domains like web.my-new-site.com, backend.my-new-site.com, etc.


### Wrong wildcard certificate

````
./gen-cert.sh wildcard.xip.io
````
Because: [Stackoverflow](https://serverfault.com/questions/933374/can-a-wildcard-ssl-certificate-secure-host-names-of-various-depths)


### Validate cert
```
openssl verify -CAfile ca/<your ca>.crt certs/<your domain at xip.io>/cert.crt
```

Example:
```
openssl verify -CAfile ca/masfernandez.crt certs/wildcard.127.0.0.1.xip.io/cert.crt
```


### Basic Nginx configuration

Configure Nginx for using the files generated in previous steps. Example:  

```
server {
  ...
  ssl_certificate /path/to/certs/<your-domain>/cert.crt;
  ssl_certificate_key /path/to/certs/<your-domain>/privkey.key;
  ssl_client_certificate /path/to/your/ca/<your-ca>.crt;
  ...
}
```


## Roadmap

See the [open issues](https://github.com/masfernandez/nginx-proxy-local-development/issues) for a list of proposed features (and known issues).


## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## License

Distributed under the MIT License. See `LICENSE.txt` for more information.


## Contact

Miguel Ángel Sánchez Fernández - mangel.sanfer@gmail.com

Project Link: [https://github.com/masfernandez/nginx-proxy-local-development](https://github.com/masfernandez/nginx-proxy-local-development)


## Acknowledgements

* [xip.io](http://xip.io/)
* [docker](https://www.docker.com/)
* README template based on: [https://github.com/othneildrew/Best-README-Template](https://github.com/othneildrew/Best-README-Template)
* CHANGELOG template based on: [https://keepachangelog.com/en/1.0.0/](https://keepachangelog.com/en/1.0.0/)

[version-shield]: https://img.shields.io/github/v/release/masfernandez/nginx-proxy-local-development?style=for-the-badge
[version]: https://github.com/masfernandez/nginx-proxy-local-development/releases

[contributors-shield]: https://img.shields.io/github/contributors/masfernandez/nginx-proxy-local-development.svg?style=for-the-badge
[contributors-url]: https://github.com/masfernandez/nginx-proxy-local-development/graphs/contributors

[forks-shield]: https://img.shields.io/github/forks/masfernandez/nginx-proxy-local-development.svg?style=for-the-badge
[forks-url]: https://github.com/masfernandez/nginx-proxy-local-development/network/members

[stars-shield]: https://img.shields.io/github/stars/masfernandez/nginx-proxy-local-development.svg?style=for-the-badge
[stars-url]: https://github.com/masfernandez/nginx-proxy-local-development/stargazers

[issues-shield]: https://img.shields.io/github/issues/masfernandez/nginx-proxy-local-development.svg?style=for-the-badge
[issues-url]: https://github.com/masfernandez/nginx-proxy-local-development/issues

[license-shield]: https://img.shields.io/github/license/masfernandez/nginx-proxy-local-development.svg?style=for-the-badge
[license-url]: https://github.com/masfernandez/nginx-proxy-local-development/blob/master/LICENSE.txt

[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/masfernandez