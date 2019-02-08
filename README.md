# Redirector's Certificate Generation

This image is not intended to be a replacement for [Certbot](https://certbot.eff.org/) or any other [ACME](https://ietf-wg-acme.github.io/acme/) client in the wild. I created it to automatize the generation and deploy of HTTPS certificates for Apache2 instances I use within containers running [mod_rewrite-Redirector](https://github.com/StayPirate/mod_rewrite-Redirector) image.

### Generation & Validation
This image is made to only work with [Let's Encrypt](https://letsencrypt.org/), if you need to use a different CA please generate and validate your certificate in a different way.  
There are some few requirements to satisfy io order to successfully use this container:
1. Having shell access to the machine.
2. Having enough privileges to run Docker containers.
3. Domian/s you want to certify already have to point the machine where you will run this container.
4. Handling port 80 for few seconds. This container uses Certbot, hence it needs to handle port 80 during the authentication process. After that the port will be released.

Keep in mind: **In order to pass the verification steps you have to run the container from the same machine pointed by the domain/s you want to generate the certificate for. Moreover, you need to be able to bind the container to port 80 during its execution.**  

---
### How to use
To generate the certificate for example.com use the following command:  
`docker container run --rm -v cert:/cert -p 80:80 tuxmealux/certify-redirector example.com`  

As you can see, we created a named volume `cert` to map the container's internal directory `/cert`. This last one, is the directory where the certificates are copied if a successfull validation is done. In this way, after the execution, we end up with our certificates inside the Docker managed volume called `cert`, while the container will be automatically deleted by the option `--rm`. We can now re-use this volume with other containers, for example with a [mod_rewrite-Redirector](https://github.com/StayPirate/mod_rewrite-Redirector) based one.

##### Many domains on one-shot
In case you want generate a certificate valid for more than one domain, and assuming that all of these are already pointing to the machine you are going to use, you just need to append all the domains to the previous command line.  
For instance, if you want to validate `example.com`, `example-2.com` and `sub.example.com`:  
`docker container run --rm -v more-cert:/cert -p 80:80 tuxmealux/certify-redirector example.com example-2.com sub.example.com`.  
If validation was succefull you will find the certificate inside a new volume named `more-cert`. Keep in mind that only one valid certificate will be generated for all the specified domains. If you want a different certificate for each domain please run the container different times, paying attenction to not override previous generated certificate.  

Use `docker volume ls` to track the volumes you created.  
If you don't want to use named volume, you can store certificates in a host system directory replacing volume options with something like `-v $(pwd)/certificate/:/cert`.

### Output
To permit the interoperability with other containers, I use the following name convention for the generated certificates:
 - **privkey.pem** - Private key for the certificate (Apache: [SSLCertificateKeyFile](https://httpd.apache.org/docs/2.4/mod/mod_ssl.html#sslcertificatekeyfile) - Nignx: [ssl_certificate_key](https://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_certificate_key)).
 - **fullchain.pem** - All certificates, including server certificate (aka leaf certificate or end-entity certificate) for your domain/s name (Apache >= 2.4.8: [SSLCertificateFile](https://httpd.apache.org/docs/2.4/mod/mod_ssl.html#sslcertificatefile) - Nginx: [ssl_certificate](https://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_certificate)). 

### What next?
 When you successfully ran this image within a container you will find the certificate stored in a volume named `cert`. You can now map this volume to other containers, as long as other containers respect the same name convention mentioned above. Or if have ran the container only to generate the certificates, then use them as you prefer.
