#My Docker Workflow

Hi everybody.
In this file I will explain how I work with Docker but it might not be the right way, and I hope people will tell me what I am doing wrong. (Open an issue, it will help!)

I am on Mac using Docker Machine, so it might change a bit if you are on Linux.

For Linux, you can definitely install Docker Machine. That way you can use VMs to have some separation with your computer and don't want to care too much about where stuff goes.

So, let's get started.

## Why?

Currently, I am working on a Java project but I might switch to another language soon and I am tired of installing a lot of things on my computer. Indeed, when I want to uninstall everything and have a clean computer again, it is tiring.

So I decided to have everything I need to be able to work with Java in Docker containers and not have Java installed on my computer. Quite hard you might say, considering you need an IDE for Java and they are written in Java and use javac to check your code. We'll see that you can put that in a container too!

## Java VM

I created a VM for Docker using the [Docker machine CLI](https://docs.docker.com/machine/):

```
    docker-machine create -d virtualbox \
        --virtualbox-hostonly-cidr "192.168.98.1/24" \
        --virtualbox-cpu-count "2" \
        --virtualbox-disk-size "10000" \
        --virtualbox-memory "4096" java
```

So, everything that I will need to develop in Java will be in this VM. It is just a VM in which Docker containers will live and die.

I am using Maven for my project, so I created a Maven image following this wunderful [tutorial from InfoQ](http://www.infoq.com/articles/docker-executable-images).
To sum up what is said here:

1. maven is going to run in a container
2. but when the container is deleted, you loose every data in it
3. so let's create a [data volume container](https://docs.docker.com/v1.8/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container) and store our maven data in it so you don't have to download all the dependencies at every build!

To create a data volume container for maven, let's do this:

```
maven_data() {
    setDockerVM java
    docker run --name maven_data \
        -v /root/.m2 \
        busybox echo 'data for maven'
}
```
You need only to do it once, then it will stay in the VM for as long as the VM lives. (Perhaps you want to make some backup regularly, probably even more when we will talk about mysql later, see the link above about data volume container. I might talk about it, not sure yet.)

So, what does this first command?
It create a data volume container from the busybox image, a small docker image. Then it runs `echo 'data for maven'` so when you see it, it's done. Why is the volume `/root/.m2`? Because in the maven container, I will use the root user and so that is where all the maven dependencies will be stored. Donc forget that the name of this data volume container is `maven_data`, it is how we will call it now!


Now, the maven container:

```
mvn() {
    setDockerVM java
    docker run --rm \
      -v $(pwd):/project \
      -m 1024m \
      --volumes-from maven_data \
      dirichlet/maven $*
  growlnotify --image "/path/to/some-picture.png" \
    -t "Maven" -m "Build finished" # bonus: some growl notification if you want it :D
}
```
This function will use my image `dirichlet/maven`, with the volumes from `maven_data` (if you listen to me, you should remember it is the name of the data volume container we created just before). to run maven with all the argument provided the `mvn` function. Cool, no? You don't have to change your habits, you will type exactly the same commands when you what to compile your project.

The `-m 1024m` is to provide 1Go of memory to the container, you might remove it or change the value, it is mainly for it to run a bit faster.

The `-v $(pwd):/project` will link the current directory to the `/project` directory. This is quite important, because maven in the image will run inside the `/project` directory. Thanks to this link, the `target` folder that contain the result of you `mvn install` commant will be on your computer! Pretty cool huh?

Twice, there was this `setDockerVM java` function call that I didn't explained. What is it?

Well, it is an handy function that set the VM java. It is handy because it starts the VM for you and set all the environment variables you need to access it. Mine is a bit verbose, but you can change it:

```
function setDockerVM() {
    echo "Docker machine $1 status:"
    state=$(docker-machine status $1)
    if [[ $state =~ (Stopped) ]]; then
        printf "Stopped, starting it...\n"
        docker-machine start $1
        printf "Started\n"
    elif [[ $state =~ (Running) ]]; then
        printf "Running\n"
    fi
    eval "$(docker-machine env $1)"
    printf "Env variables set, ready to go!\n"
}
```

So cool, so far we can build a maven project that we have. But now, we want to edit it, it might be useful.

### Running container with display

Here, I will use an awesome [post](https://blog.jessfraz.com/post/docker-containers-on-the-desktop/) of the blog of Jessie Frazelle to run Netbeans.

Indeed, you need to access some kind of display for Netbeans, not just command line. Here, on Mac, we are going to need:

- [xQuartz](http://www.xquartz.org) either from the website or with [Homebrew](http://brew.sh)
- A command that you need to keep running as long as you have containers that need display. [source](https://github.com/docker/docker/issues/8710)
- My wonderful [Netbeans Docker image](https://hub.docker.com/r/dirichlet/netbeans/), copied from [here](https://github.com/fgrehm/docker-netbeans) in order to keep it up to date and unfortunatly already outdated (need to move to 8.1, currently 8.0.2, will do)

So, once xQuartz installed, you can keep this script running in a terminal (easier to stop it, and because I don't really know what it does, I like to stop it when I don't use it.)

```
usesocat() {
	socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"
}
```

#### Side note
All this part about `xQuartz` and `socat` is not needed on Linux as far as I know. You might need to toy around with what to put in the `-e DISPLAY=` when running the container if you are running it in a VM.

Then run Netbeans:

```
netbeans() {
    setDocker java
    docker run -ti --rm \
           -e DISPLAY=192.168.98.1:0 \
           -m 3072m \
           -v $HOME/dotfiles/.netbeans-docker:/root/.netbeans \
           -v $(pwd):/workspace \
           --volumes-from maven_data \
           --name netbeans \
           dirichlet/netbeans
}
```

So what I do here is:

- `-e DISPLAY=192.168.98.1:0` I link the display to the container
- `-m 3072m` I provide Netbeans with some extended memory, because it is constantly doing stuff on the backgound so... You often end up with low memory warning and no completion if you don't do that.
- `-v $HOME/dotfiles/.netbeans-docker:/root/.netbeans` will allow you to store your Netbeans preferences and plugins somewhere on your computer. Something that I found quite valuable. You need to go to **Tools > Plugins > Settings tab > Advanced section > Plugin Install Location** set it to Force install into user directory in Netbeans to force the plugins to be installed in `/root/.netbeans` in the container and so to be persisted on your computer.
- `--volumes-from maven_data` is to have the dependencies got from your `mvn install` or whatever picked up by Netbeans.

##### Side note

I have been giving to maven and Netbeans quite a lot of memory (4096Mo). You can adjust that to your configuration, you need also to change the memory allocated to the VMs. By default it is 1Go which was not really enough for the Java VM that we are building so I gave it 4Go. You can make some trials to see what's best for you.


## Server VM
TODO. (glassfish, etc.)

In this part, we'll see how to setup a development server.


Create a MySQL data container:

```
docker create --name mysql_data -v /var/lib/mysql busybox
```

Make a backup of it:

```
docker run --rm \
--volumes-from mysql_data \
-v "$(pwd)":/backups \
-ti ubuntu \
tar cvzf /backups/docker-mysql-`date +%y%m%d-%H%M%S`.tgz /var/lib/mysql
```

#### Side note
The reason why I am creating several VMs is because they grow over time. First I was using only one, and it is now taking 16Go on my computer, so I'm splitting them up. I can then easily delete the ones that are not needed anymore. If I want to try to build some image before putting on Docker Hub or using it locally, I first build it in a `build` VM created just for that, and then I delete it.


## Tips

To finish, lets give some tips that I think can be usefull:

- If you want to do something in containers, don't build it from the ground up. There are so much images out there, you can be sure someone did something close to what you need.
- You might end up with things that don't work the way you expected: don't forget that containers aren't really running Ubuntu, so a lot of functionalities might be missing.

Some more personal issues I had:

- Some containers might not be built from ca-certs or at least not have ca-certs so SSL won't work (yay!)
- The image of Java used for Glassfish doesn't contain one certificate from GoDaddy (cf this [thread](http://stackoverflow.com/a/27194959/4140425))