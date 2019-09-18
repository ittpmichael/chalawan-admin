# !/bin/bash

echo "Downloading bazel repository file..."
wget https://copr.fedorainfracloud.org/coprs/vbatts/bazel/repo/epel-7/vbatts-bazel-epel-7.repo
if [ $? -eq 0 ]; then
	echo "done";
fi

echo "Copy repo file to /etc/yum.repos.d..."
sudo cp vbatts-bazel-epel-7.repo /etc/yum.repos.d/
if [ $? -eq 0 ]; then
	echo "done";
	rm vbatts-bazel-epel-7.repo;
fi

echo "The bazel repository has been added."
echo "Use 'sudo yum install -y bazel' to install bazel"
