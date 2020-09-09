# Attempted answers to some common questions asked during the guild

## What's the difference between Vagrant and VirtualBox.
- Think of VirtualBox as being the actual infrastructure provider (the virtualization platform which runs the VMs) and Vagrant as being clever and clean way to interact with VirtualBox such that with a single Vagrantfile you're able to spin up multiple VMs on VirtualBox with the exact same configuration, instead of having to manually and repetitively click through the VirtualBox GUI X times if you want to provision X machines (or figure out how to script against the VirtualBox API yourself,  although that's still a step better).

In fact, Vagrant doesn't just work with VirtualBox, VirtualBox is just one of the many providers (https://www.vagrantup.com/docs/providers) that ship with Vagrant out of the box (VirtualBox just happens to be the default provider, hence we used it in the short guild exercise). So think of Vagrant as a nice and uniform (in principle) way of writing configuration for different backend infrastructure providers (various virtualization, containerization, or cloud platforms, eg. VMWare, Docker, AWS).

A parallel (and this will probably make more sense once you get to week 2 and 3) would be something like Terraform, which also works with various backend infrastructure providers (https://www.terraform.io/docs/providers/index.html) - that is, you can write terraform to spin up infrastructure in AWS, or in Azure, or in GCP, those are just different providers you plug in. In fact, you could even write Terraform to provision Helm charts and GoCD pipelines 😱

Perhaps the following links might illuminate things a little more:
- https://www.quora.com/Whats-the-difference-between-a-VM-Docker-and-Vagrant
- https://www.vagrantup.com/intro/vs/terraform.html (in case you were wondering, if I can use Vagrant with an AWS provider as well, what the heck is terraform for then? Why don't I use Vagrant for everything?)

## I can't seem to run the service with a non-root user because I can't pass in the user password
- Firstly, the reason we don't want to run the application as root is just segregation + principle of least privilege (assuming everyone finished their mandatory security awareness mods by now lol). Root users have permissions to do a lot of potentially bad things to your system which you do not want to grant your application, otherwise someone who found a way to hijack your app to do bad stuff would be able to do bad stuff to your whole system

- Conceptually, we can differentiate between user accounts and service accounts (it's a concept that you will see in AWS (under IAM) and Kubernetes land as well, or probably anywhere we talk about access control). A user account is meant to be used by an actual human user, and in linux land user accounts will have passwords and login shells (you can see the list of users on a linux system typically inside the /etc/passwd file), whereas a service account is usually meant to be used by system services (eg. maybe a logrotate or chronyd daemon running on your linux box, or your java application itself) or generally any non-human thing that needs to be granted a certain security context (certain permissions, access etc) to do stuff. Also, service accounts generally don't have a login shell, nor do they have a password (this is different than having an empty password!), which means you can never actually login as a service account and do stuff in bash, for example. See https://security.stackexchange.com/questions/166426/why-do-some-people-think-linux-machine-accounts-with-passwords-are-more-secure-t

- So you should basically be creating a service account with no password to run your java application (also, user account vs service account is more like a logical/semantic distinction, not a hard technical distinction - as mentioned the main difference is the lack of password and login shell for the latter, and the OS doesn't actually distinguish where the users are stored (/etc/passwd) or how you create them (typically a command like useradd or adduser, depending on the Linux distro)

- Generally, it's good practice to create one service account per service (segregation - if one service gets hacked that user will have limited surface of attack because it can't mess with another service too). You should have seen a couple of accounts out of box in /etc/passwd already, those are for running the various default system services and daemons on a default linux box, like mail for the mailserver. See for example standard users on RHEL: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/deployment_guide/s1-users-groups-standard-users

More:
- https://unix.stackexchange.com/questions/314725/what-is-the-difference-between-user-and-service-account
- https://unix.stackexchange.com/questions/197124/why-are-there-many-accounts-im-the-only-user/197155#197155
- https://unix.stackexchange.com/questions/115177/how-come-each-program-or-service-has-an-account-of-its-own-in-etc-passwd/115184#115184
- This book: https://www.amazon.com/UNIX-Linux-System-Administration-Handbook/dp/0134277554 has a whole section on user and access management iirc


## Wanted to ask if anyone knows when we run a JAR file as a service (systemd, in this case) on ubuntu, what user is used to run the JAR file? Is it root?

Answering this question requires understanding a little bit more about `systemd`; I couldn't answer this thoroughly  (ie. throw out something other than "oh, it's always root by default") at first so I dug in a little bit more.

You can get most of the answer from `User=,Group` option documented in the `systemd.exec` man page: https://www.freedesktop.org/software/systemd/man/systemd.exec.html  (you can also run `man systemd.exec` in your linux box to get this)

```
User=, Group=
           Set the UNIX user or group that the processes are executed as, respectively. Takes a single user or group name, or a numeric ID as argument. For *system services* (services run by the system service manager, i.e.managed by PID 1) and for user services of the root user (services managed by root's instance of systemd --user), the default is "root", but User= may be used to specify a different user. *For user services of any other user, switching user identity is not permitted, hence the only valid setting is the same user the user's service manager is running as*. If no group is set, the default group of the user is used. This setting does not affect commands whose command line is prefixed with "+".
```
(bolding my own)

So to understand this fully, we need to understand the distinction between the *system service manager* vs *user service manager instances* (the service manager = systemd). Basically, the manpage says that if the service is being run by the system service manager, or the `root` user's systemd instance, the default user used to run the service is `root` (if you omit setting the user via `User=` in your unit file). It also pretty much says that setting the `User=` and `Group=` options are basically only valid for services to be run by the *system* service manager instance, since, if the service is being run by a user systemd instance, your service should be run with the same user running that systemd instance anyway.

So what is this *system service manager* vs *user service manager instances* thing? From the systemd manpage: https://www.freedesktop.org/software/systemd/man/systemd.html#

```
systemd is a system and service manager for Linux operating systems. When run as first process on boot (as PID 1), it acts as init system that brings up and maintains userspace services. *Separate instances are started for logged-in users to start their services.*

systemd is usually not invoked directly by the user, but is installed as the /sbin/init symlink and started during early boot. The user manager instances are started automatically through the user@.service(5) service.
```

In other words, there can be multiple systemd instances running, the system one being the very first one that runs on boot (PID 1), and the ones that are subsequently started when users login (or can be configured to start on boot time as well); these user systemd instances can be used to manage services and other systemd units specific to that user. See https://wiki.archlinux.org/index.php/Systemd/User and https://www.freedesktop.org/software/systemd/man/user@.service.html# for more.

So specifically in the guild example, where we want to run this java service using a service account (non-human user), which systemd instance should the service be running under? Since we want this java service to always be running to serve traffic to the outside world, and not controlled in a way that's tied to any specific machine users, this service should run under the system systemd instance. So in other words, yes, its user will default to `root` unless we explicitly set `User=` in the unit file.

How do I know whether my systemd unit is running under the system instance or a user-specific instance? You can `vagrant ssh` into your ubuntu box and try this:

Run `systemctl --system` and read through the output -> this will list through all the units managed by the system systemd instance. In fact, if you omit `--system` and just type `systemctl` it lists units managed under the system instance by default.

If you would like to see the units managed by the user instance (for your current logged in user, which if you did `vagrant ssh`, would be `vagrant` by default), run `systemctl --user`

You can see that most of the default services are actually being run by the system instance, not the user one.

Also when you do stuff like `systemctl enable X` and `systemctl restart X`, those are executed by default by the system instance, unless you pass in the `--user` flag, in which case it'll invoke the user instance of the current logged in user.

Whew, lots of deep systemd stuff there that I'm also not that fluent in 💦
