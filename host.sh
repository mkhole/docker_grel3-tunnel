#/bin/sh

source ./env.file

# iptables
IPTABLE_RULE="-s ${ENV_GRE_REMOTE_IP}/32 -p gre -j DNAT --to-destination $ENV_DOCKER_IP"
if iptables -t nat -N DOCKER > /dev/null 2>&1; then
	iptables -t nat -N DOCKER
	iptables -t nat -A DOCKER $IPTABLE_RULE
else
	if ! iptables -t nat -S | grep -e "$IPTABLE_RULE" > /dev/null 2>&1; then
		iptables -t nat -A DOCKER $IPTABLE_RULE
	fi
fi

IPTABLE_RULE="-s ${ENV_GRE_REMOTE_IP}/32 -o docker0 -p gre -j ACCEPT"
if iptables -N DOCKER > /dev/null 2>&1; then
	iptables -N DOCKER
	iptables -A DOCKER $IPTABLE_RULE
else
	if ! iptables -S | grep -e "$IPTABLE_RULE" > /dev/null 2>&1; then
		iptables -A DOCKER $IPTABLE_RULE
	fi
fi

# docker

docker run \
	--name grel3-tunnel \
	--env-file ./env.file \
	-v /lib/modules:/lib/modules:ro \
	-d --privileged \
	mkhole/grel3-tunnel:1.0
