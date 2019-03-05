#!/bin/bash

DINAME="codicus/transmission-from-source:latest"
DCNAME="transmission"
HOSTNAME="transmission.net.lan"

NO_ARGS=0
E_OPTERR=65

if [ $# -eq "$NO_ARGS" ]
then
  printf "No arguments.\n"
  printf "Usage: $0 {-build|-run|-restart|-rmf|-rmfa|-exec|-logsf|-none}\n"
  printf " $0 -build - build image $DINAME\n"
  printf " $0 -run - create and start container $DCNAME\n"
  printf " $0 -restart - restart container $DCNAME\n"
  printf " $0 -rmf - remove container $DCNAME (docker rm -f $DCNAME)\n"
  printf " $0 -rmfa - remove all containers (docker rm -f \$(dokcer ps -a -q)\n"
  printf " $0 -exec - run a command in a running container $DCNAME (docker exec -it $DCNAME /bin/bash)\n"
  printf " $0 -logsf - fetch the log of a container with follow option $DCNAME (docker logs -f $DCNAME)\n"
  printf " $0 -none - remove image when repository NONE\n"
  exit $E_OPTERR
fi

while :; do
	case "$1" in
	-build)
	  docker build -t $DINAME .
	 ;;
	-run)
	  docker run --detach \
	  --restart=always \
	  --hostname $HOSTNAME \
	  --publish 9091:9091 \
	  -v $PWD/volumes/complete:/trans/complete \
	  -v $PWD/volumes/incomplete:/trans/incomplete \
	  -v $PWD/volumes/watch:/trans/watch \
	  -v $PWD/volumes/config:/trans/config \
	  -e ADM_USER=user \
	  -e ADM_PASSWD=pass \
	  --name $DCNAME \
	  $DINAME
	 ;;
	-restart)
	  docker restart $DCNAME
	 ;;
	-rmf)
	  docker rm -f $DCNAME
	 ;;
	-rmfa)
	  docker rm -f $(docker ps -a -q)
	 ;;
	-exec)
	  docker exec -it $DCNAME /bin/bash
	 ;;
	-logsf)
	  docker logs -f $DCNAME
	 ;;
	-none)
	  docker rmi $(docker images -f "dangling=true" -q)
	 ;;
	--)
	  shift
	 ;;
	?* | -?*)
	  printf 'WARNING! Unknown argument (ignored): %s\n' "$1" >&2
	 ;;
	*)
	  break
	esac
	shift
done

exit 0