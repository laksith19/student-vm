OUT_DIR = out
IMAGE_FILE_QCOW2 = $(OUT_DIR)/cs162-student-vm.qcow2
IMAGE_FILE_OVA = $(OUT_DIR)/cs162-student-vm.ova
SEED_FILE = $(OUT_DIR)/seed.iso

DOCKER_IMAGE_NAME = cs162-student-vm
DOCKER_CONTAINER_NAME = cs162-student-vm

.PHONY: all
all: $(IMAGE_FILE_QCOW2) $(IMAGE_FILE_OVA)
	$(MAKE) dockerkill

# Touch the directory so it's up to date.
$(OUT_DIR):
	mkdir -p $(OUT_DIR)
	touch $(OUT_DIR)

# Copy the QCOW2 image from the docker container to the filesystem.
$(IMAGE_FILE_QCOW2): $(OUT_DIR) dockerstart
	docker cp $(DOCKER_CONTAINER_NAME):/cs162-student-vm/cs162-student-vm.qcow2 $(IMAGE_FILE_QCOW2)

# Copy the OVA image from the docker container to the filesystem.
$(IMAGE_FILE_OVA): $(OUT_DIR) dockerstart
	docker cp $(DOCKER_CONTAINER_NAME):/cs162-student-vm/cs162-student-vm.ova $(IMAGE_FILE_OVA)
	
# Copy the config seed.iso from the docker container to the filesystem.
$(SEED_FILE): $(OUT_DIR) dockerstart
	docker cp $(DOCKER_CONTAINER_NAME):/cs162-student-vm/seed.iso $(SEED_FILE)

.PHONY: dockerstart
dockerstart:
	$(MAKE) dockerkill
	docker build -t $(DOCKER_IMAGE_NAME) .
	docker run --name $(DOCKER_CONTAINER_NAME) -td --rm $(DOCKER_IMAGE_NAME)

.PHONY: dockerkill
dockerkill:
	docker rm -f $(DOCKER_IMAGE_NAME)

.PHONY: clean
clean: dockerkill
	rm -rf $(OUT_DIR)
	docker image rm \
		$(DOCKER_IMAGE_NAME) \
		2>/dev/null || :
	docker rm -f $(DOCKER_CONTAINER_NAME)
