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
	if ! /sbin/init --version | grep systemd >/dev/null ; then
		echo "This script only supports systemd. Feel free to update for other init systems. Sorry."
		exit 1
	fi
}

check_nvidia() {
	echo -e "\\n\e[4mNVIDIA\e[0m\\n"

	# Check if Nvidia GPUs are available
	NVIDIA_GPU_COUNT=$(ls /dev | egrep "${NVIDIA_DEVICE_REGEX}"  | wc -l)
	if [ "${NVIDIA_GPU_COUNT}" -eq 0 ]; then
		printf "No Nvidia GPUs found.\\n"
	else
		nvidia-smi

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
	fi

	if [ ${NVIDIA_GPU_AVAILABLE} = 1 ]; then
		printf "\\nNvidia GPU will be used for mining - YES\\n"
	else
		printf "\\nNvidia GPU will be used for mining - NO (Check your configuration)\\n"
	fi
}

# TODO when I get a Vega 56
check_amd() {
	echo -e "\\n\e[4mAMD\e[0m"
	printf "\\nAMD GPU not implemented currently !\\n"
}

check_cpu() {
	echo -e "\\n\e[4mCPU\e[0m"
	CPU_INFO=$(cat /proc/cpuinfo)
	CPU_MODEL=$(echo "${CPU_INFO}" | grep "model name" | head -1 | cut -d: -f2)
	CPU_CORE_COUNT=$(echo "${CPU_INFO}" | grep "cpu cores" | head -1 | cut -d: -f2)
	CPU_LOGICAL_CORE_COUNT=$(echo "${CPU_INFO}" | grep "processor" | wc -l)
	printf "\\nModel =%s\\nPhysical core count = %d\\nLogical core count = %d\\n" "${CPU_MODEL}" "${CPU_CORE_COUNT}" "${CPU_LOGICAL_CORE_COUNT}"
}

check_hardware() {
	printf "\\nChecking devices ...\\n"

	check_cpu
	check_nvidia
	check_amd
}

check_hardware

#export CPU_COUNT=$(cat /proc/cpuinfo | grep processor -c)

# Ensure that the miners are running at really low priorities (Start two due to logical processors - One instance only uses half the cores)
#nice -19 docker-compose up --scale cpuminer=1 -d \
#	&& sudo renice 19 -p $(pgrep minerd)
