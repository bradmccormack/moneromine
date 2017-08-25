#!/bin/bash

# A simple script to ensure that pre-requisites are installed for mining on the CPU and GPU for Monero cryptocurrency.

# Tested on Arch Linux
readonly NVIDIA_DEVICE_REGEX="nvidia[0-9]"
readonly NVIDIA_HELPER="nvidia-docker"
readonly NVIDIA_HELPER_URL="https://github.com/NVIDIA/nvidia-docker"
readonly NVIDIA_DAEMON="nvidia-docker"

NVIDIA_GPU_AVAILABLE=0
AMD_GPU_AVAILABLE=0

check_env() {
	# Ensure that the appropriate environment variables are set
	if [ -z "${MONERO_EMAIL}" ]; then
		echo "Please set the MONERO_EMAIL environment variable"
		exit 1
	fi

	if [ -z "${MONERO_WALLET_ID}" ]; then
		echo "Please set the MONARO_WALLET_ID environment variable"
		exit 1
	fi
	
	# This script only supports systemd
	if ! /sbin/init --version | grep systemd; then
		echo "This script only supports systemd. Feel free to update for other init systems. Sorry."
		exit 1
	fi
}

check_nvidia_deps() {
	printf "\\nNumber of Nvidia GPUs found = %d" "${NVIDIA_GPU_COUNT}"
	
	# Make sure that nvidia-docker is available (Nvidia's helpers)
	if ! type -p "${NVIDIA_HELPER}" > /dev/null ; then
		printf "\\n%s was not found. %s is required to mine using the NVidia GPU in a Docker container.\\nPlease see %s for installation instructions.\\n" \
			"${NVIDIA_HELPER}" "${NVIDIA_HELPER}"  "${NVIDIA_HELPER_URL}" 
		exit 1
	else
		printf "\\n%s helper script available - SUCCESS" "${NVIDIA_HELPER}"

		if systemctl is-active ${NVIDIA_DAEMON} | grep 'inactive' > /dev/null ; then
			printf "\\nThe %s daemon needs to be active. Please start it with systemctl start %s.\\nEnable it at boot with systemctl enable %s.\\n" \
				"${NVIDIA_DAEMON}" "${NVIDIA_DAEMON}" "${NVIDIA_DAEMON}"
		else
			printf "\\n%s daemon active - SUCCESS\\n" "${NVIDIA_DAEMON}"
			NVIDIA_GPU_AVAILABLE=1
		fi
	fi
}

# TODO when I get a Vega 56
check_amd_deps() {
	printf "\\nAMD GPU not implemented !\\n"
	exit 1
}

check_hardware() {
	printf "\\nChecking devices ...\\n"

	# Check if Nvidia GPUs are available
	NVIDIA_GPU_COUNT=$(ls /dev | egrep "${NVIDIA_DEVICE_REGEX}"  | wc -l)
	if [ "${NVIDIA_GPU_COUNT}" -eq 0 ]; then
		printf "No Nvidia GPUs found.\\n"
		exit 1
	else
		check_nvidia_deps
	fi
}

check_env
check_hardware

#export CPU_COUNT=$(cat /proc/cpuinfo | grep processor -c)

# Ensure that the miners are running at really low priorities (Start two due to logical processors - One instance only uses half the cores)
#nice -19 docker-compose up --scale cpuminer=1 -d \
#	&& sudo renice 19 -p $(pgrep minerd)
