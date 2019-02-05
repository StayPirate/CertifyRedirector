# Redirector's Certificate Generation

### Why this image?
This image is not intended to be a replacement for [Certbot](https://certbot.eff.org/) or other [ACME](https://ietf-wg-acme.github.io/acme/) clients in the wild. I created it to quickly generate and deploy certificates for Apache2 instances I use within other containers and act as redirectors in my C2 infrastructure. If you already using [mod_rewrite-Redirector](https://asd), you will find this image quite useful.

### Certificate Generation
**To pass the verification step you have to run the container from the same machine pointed by the domains that you want to generate the certificate for. Moreover, you need to be able to bind the container to port 80 during the verification step.**
In order to generate the certificate for your domain/domains, you just need to run the following command:
```docker container run -v cert:/cert StayPirate/CertifyRedirector domain_1 domain_2 sub.domain_2```.
You can specify one or as many domains you want, the output will be one certificate valid for all the domains which have successfully passed the verification steps. If you want a single certificate for each domain, please run the container different times. Be careful to not override certificates generated previously.

After you ran the above-mentioned command, a new volume named `cert` is created and managed the Docker daemon. It will still be available even if you remove the container which has created it. Except if you use the flag `-v` in `docker container rm -v conatiner_name`. In this case, the volume will be deleted along with its content.

### Using the certificate
After you properly ran this image within a container, the certificate will be stored in a volume named `cert`. You can use this volume with other containers, as long as they use the same format and pathnames used here for their certificates. In order to do that, at the creation time of the new container, you need to mount this same volume. For instance using [mod_rewrite-Redirector](https://asd) image: 
```docker container run -p 443:8000 -v $(pwd)/htaccess:/var/www/html/.htaccess -v cert:/cert StayPirate/mod_rewrite-Redirector```
