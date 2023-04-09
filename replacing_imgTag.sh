#!/bin/bash
sed "s/img_tag/$1/g" K8S_pod.yml > K8S_pod__updated.yml
