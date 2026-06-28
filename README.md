# trigger_tf_mlm
trigger terraform after CI of mlm test push success
--
terraform deploys vpc+subnets+route tables, private+public, Nat+igw to serve.
eks, and helm load balancer aws controller, and the helm chart of the deployment of the app-  https://github.com/meditator3/mlm_test

CI triggered here by push for the app's original repo - will update image tag of helm chart using terraform, and CD the app using helm

also, before main infra is deployed - a state bucket s3, is deployed, to manage terraform better later locally, using backend tf.

