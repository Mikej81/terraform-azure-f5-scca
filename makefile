.PHONY: build run test azure shell destroy

export DIR = $(shell pwd)
export WORK_DIR = $(shell dirname ${DIR})
export CONTAINER_IMAGE = "f5-scca-terraform"

run: build shell

build:
	docker build -t ${CONTAINER_IMAGE} .

shell:
	@echo "tf shell ${WORK_DIR}"
	@docker run --rm -it \
	--volume ${DIR}:/workspace \
	-e ARM_CLIENT_ID=${ARM_CLIENT_ID} \
	-e ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET} \
	-e ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
	-e ARM_TENANT_ID=${ARM_TENANT_ID} \
	-v ${SSH_KEY_DIR}/:/root/.ssh/:ro \
	f5-scca-terraform \


azure:
	@#terraform init, plan, apply
	@echo "init, plan, apply"
	@docker run --rm -it \
	--volume ${DIR}:/workspace \
	-e ARM_CLIENT_ID=${ARM_CLIENT_ID} \
	-e ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET} \
	-e ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
	-e ARM_TENANT_ID=${ARM_TENANT_ID} \
	f5-scca-terraform \
	sh -c "terraform init; terraform plan; terraform apply --auto-approve"

destroy:
	@#terraform destroy --auto-approve
	@echo "destroy"
	@docker run --rm -it \
	--volume ${DIR}:/workspace \
	-e ARM_CLIENT_ID=${ARM_CLIENT_ID} \
	-e ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET} \
	-e ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
	-e ARM_TENANT_ID=${ARM_TENANT_ID} \
	f5-scca-terraform \
	sh -c "terraform destroy --auto-approve"


test: test1

test1:
	@echo "terraform install"
	@docker run --rm -it \
	--volume ${DIR}:/workspace \
	-e ARM_CLIENT_ID=${ARM_CLIENT_ID} \
	-e ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET} \
	-e ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
	-e ARM_TENANT_ID=${ARM_TENANT_ID} \
	f5-scca-terraform \
	sh -c "terraform --version "
