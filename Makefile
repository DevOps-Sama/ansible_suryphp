cnf ?= .env
ifneq ($(shell test -e $(cnf) && echo -n yes), yes)
	ERROR := $(error $(cnf) file not defined in current directory)
endif

include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

define awsdata
$(eval VPC_ID=$(shell aws ec2 describe-vpcs \
	--filters Name=is-default,Values=true \
	--query Vpcs[0].VpcId \
	--output text \
	--region ${AWS_REGION} \
	--no-cli-pager\
))
$(eval VPC_SUBNET_ID=$(shell aws ec2 describe-subnets \
	--filters Name=vpc-id,Values=vpc-0034163fa9f83d0ca \
	--query Subnets[0].SubnetId \
	--output text \
	--region ${AWS_REGION} \
	--no-cli-pager\
))
$(eval AMI_ID=$(shell aws ec2 describe-images \
	--filters Name=name,Values=${AWS_IMAGE_NAME} \
	Name=owner-id,Values=${AWS_IMAGE_OWNER} \
	--query 'sort_by(Images, &CreationDate)[-1].ImageId' \
	--output text \
	--region ${AWS_REGION} \
	--no-cli-pager\
))
endef

.DEFAULT_GOAL := test

.PHONY: aws
aws: test

.PHONY: converge
converge:
	$(call awsdata)
	VPC_ID=$(VPC_ID) VPC_SUBNET_ID=$(VPC_SUBNET_ID) AMI_ID=$(AMI_ID) \
	molecule converge

destroy:
	$(call awsdata)
	VPC_ID=$(VPC_ID) VPC_SUBNET_ID=$(VPC_SUBNET_ID) AMI_ID=$(AMI_ID) \
	molecule destroy

.PHONY: test
test:
	$(call awsdata)
	VPC_ID=$(VPC_ID) VPC_SUBNET_ID=$(VPC_SUBNET_ID) AMI_ID=$(AMI_ID) \
	molecule test

.PHONY: vagrant
vagrant:
	molecule test -c vagrant
