# Project Title



## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Install Docker for your platform

* Windows - https://docs.docker.com/toolbox/toolbox_install_windows/
* Mac - https://docs.docker.com/docker-for-mac/install/
* Linux - Please consult your distro


### Installing

```
Ensure the Docker service is running and execute the following

```
chmod +x start.sh
./start.sh
```

## Deployment

TODO - Add additional notes about how to deploy this on a live system and manage it (docker-compose up etc)

## Contributing

TODO - Add a CONTRIBUTING.md file and link here

## Authors

* **Brad McCormack** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

Thanks to Nvidia for their Docker base images

* https://hub.docker.com/r/nvidia/cuda/
* https://github.com/NVIDIA/nvidia-docker/wiki/Image-inspection#nvidia-docker
* https://github.com/eywalker/nvidia-docker-compose

## TODO

* Use Alpine as the base Docker image and port Nvidia build instructions over to reduce the image size
* Roll my own cpu image and don't rely on servethehome/monero_dwarfpool:zen as it's not obvious how that image was constructed (I couldn't find the Dockerfile)
* AMD GPU support
* Customize the mining pool via environment variables or Docker tags
* Consider creating a very simple web service in Go with a web view to control the containers and observe progress (Without using Docker attach etc)
* See if there are faster GPU mining programs and swap out ccminer (xmrminer ??)
* Consider CUDA_CACHE_PATH


