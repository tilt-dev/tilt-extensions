# local_output

Author: [Çağatay Yücelen](https://github.com/cyucelen)

Wait until command output is equal to given output.

`wait_for_it` runs given command and checks if output is equal to expected output. Retry limit and backoff time can be specified.
This extension can be useful in situations like waiting for your server, database is healthy.


## Usage

Pass a command and expected output to wait until your expectation met.

### Example:

```python
wait_for_it('minikube status | grep Running | wc -l | tr -d " "', expected_output='3')
```

Original `minikube status` command output:
```
m01
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

### Arguments:

- `command`: shell command to execute and get output
- `expected_output`: output value to retry until met
- `backoff`: sleep duration between retries
- `retry_limit`: count of total retries before fail
