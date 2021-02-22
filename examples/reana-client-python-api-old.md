---
title: "How to run workflows using REANA client Python API"
date: 2021-02-22T15:00:00+01:00
tags:
  - API
  - client
  - Python
---

Here you can find a step by step guide on how to submit workflows to
REANA using the client Python API. It might be useful while integrating
REANA workflow submissions with other Python based systems or to
programmatically launch workflows under certain conditions instead of doing
it manually. This is a simple example, for illustrative purposes,
using the [Serial](http://docs.reana.io/running-workflows/supported-systems/serial/)
workflow engine and a simple [ROOT6 RooFit analysis](https://github.com/reanahub/reana-demo-root6-roofit/)
example. We will create a new workflow, run it and retrieve its results
using the REANA client Python API.
<!--more-->

### Installing prerequisites

The main prerequisite to follow this guide is to install `reana-client`, if you
haven't done that already:
```
$ pip install --user reana-client==0.7.2
```

To display the output images which our workflow will produce we can use Python
Imaging Library `Pillow`. If you don't have it installed in your machine,
here is how you can do it:

```
$ pip install --user Pillow
```

### Configuring access

As a first step let's set up the environment variable `REANA_SERVER_URL`.
This variable is mandatory and should point to the remote REANA cluster
instance that will be used to run our computations. The client code will
use this environment variable automatically to connect to the remote REANA
cluster later on. The typical value is https://reana.cern.ch for CERN deployments.
Here is how we can set it:

```python
import os

if not os.getenv('REANA_SERVER_URL'):
    os.environ['REANA_SERVER_URL'] = 'https://reana.cern.ch'
```

In order for REANA client to successfully connect to remote cluster
we also need to specify another mandatory variable `REANA_ACCESS_TOKEN`. One way
to obtain it is by opening https://reana.cern.ch/ on your browser, signing in
with your CERN credentials and navigating to your profile. Remember to keep it
safe and private, since this is your main key to access REANA cluster.
Let's set it up:

```python
from getpass import getpass

my_reana_token = \
    os.getenv("REANA_ACCESS_TOKEN") or getpass('Enter your REANA token: ')
```

### Specifying workflow

Once all the configurations to connect to REANA cluster are set up, we can focus
on our workflow creation. As a first step let's choose a name for the workflow
and the kind of workflow specification we will use:

```python
my_workflow_name = 'root6-roofit'
my_workflow_type = 'serial'
```

Now we can declare what kind of inputs our workflow will have to use.
Please refer to [reana.yaml](https://github.com/reanahub/reana-demo-root6-roofit/blob/f29e98b482fe8cb801735ac2fa48bc01e6cc05b7/reana.yaml#L2-L9)
for correspondence. Inputs consist of files and parameters and can be specified like this:

```python
my_inputs = {
    'files': [
        'code/gendata.C',
        'code/fitdata.C'
    ],  # A list of files your analysis will be using
    'parameters': {
        'events': '20000',
        'data': 'results/data.root',
        'plot': 'results/plot.png',
    }  # Parameters for your workflow
}
```

Finally we need to provide the actual workflow specification where all the
computational steps needed to run our analysis are described. For correspondence
please refer to [reana.yaml](https://github.com/reanahub/reana-demo-root6-roofit/blob/f29e98b482fe8cb801735ac2fa48bc01e6cc05b7/reana.yaml#L13-L22).
The analysis will consist of two stages. In the first stage, signal and
background are generated. In the second stage, a fit will be made for the
signal and background. Here is how we can define the workflow steps:

```python
my_workflow = {
    'steps': [
        {
            'name': 'gendata',
            'environment': 'reanahub/reana-env-root6:6.18.04',
            'commands': [
                'mkdir -p results',
                'root -b -q \'code/gendata.C(${events},"${data}")\' | tee gendata.log',
            ],
        },
        {
            'name': 'fitdata',
            'environment': 'reanahub/reana-env-root6:6.18.04',
            'commands': [
                'root -b -q \'code/fitdata.C("${data}","${plot}")\' | tee fitdata.log'
            ],
        },
    ]
}
```

### Creating workflow

Finally, once all the workflow steps are specified, we are ready to create it
in REANA. To create the workflow using REANA client we could use the [create](https://reana-client.readthedocs.io/en/maint-0.7/#reana-client-create)
command. In our case we can use `create_workflow_from_json` function
where we need to define all the needed parameters:

```python
from reana_client.api.client import create_workflow_from_json

create_workflow_from_json(
    workflow_json=my_workflow,
    name=my_workflow_name,
    access_token=my_reana_token,
    parameters=my_inputs,
    workflow_engine=my_workflow_type)
```

Output:

```python
{
  'message': 'Workflow workspace created',
  'workflow_id': '6cd613eb-f2fb-411b-9601-c89599925759',
  'workflow_name': 'root6-roofit'
}
```

### Uploading files

After creating our workflow we also need to upload all the input files to
the workflow workspace. Same functionality can be achieved with REANA client
[upload](https://reana-client.readthedocs.io/en/maint-0.7/#reana-client-upload)
command. It can be done as follows:

```python
from reana_client.api.client import upload_to_server

abs_path_to_input_files = [os.path.abspath(f) for f in my_inputs['files']]
upload_to_server(my_workflow_name, abs_path_to_input_files, my_reana_token)
```

### Starting workflow

At this point we have done all what is needed to start our workflow in REANA.
To do it with REANA client we could call [start](https://reana-client.readthedocs.io/en/maint-0.7/#reana-client-start)
command. But in this case it can be started by simply calling `start_workflow`
function and defining workflow name and access token. Additionally, we
can also override workflow parameters while starting the workflow, but let's
keep the original ones for now:

```python
from reana_client.api.client import start_workflow

start_workflow(my_workflow_name, my_reana_token, {})
```

Output:

```python
{
  'message': 'Workflow submitted.',
  'run_number': 1,
  'status': 'queued',
  'user': '1d27737b-5b80-4da2-87bb-816a20e110bd',
  'workflow_id': '6cd613eb-f2fb-411b-9601-c89599925759',
  'workflow_name': 'root6-roofit'
}
```

### Checking workflow status

After starting our workflow we might want to check its current status.
To inspect the workflow status using REANA client we could use [status](https://reana-client.readthedocs.io/en/maint-0.7/#reana-client-status)
command. Similarly, it can be achieved with `get_workflow_status` function.
Since it will take couple of seconds for all the computations to be finished
while executing our workflow, we will use a loop to wait and regularly check
what is the current status of our workflow:

```python
import time
from reana_client.api.client import get_workflow_status

while True:
    status_details = get_workflow_status(my_workflow_name, my_reana_token)
    print('Current status: ', status_details['status'])
    if status_details['status'] == 'finished':
        break
    time.sleep(1)
```

Output:

```python
Current status:  running
...
Current status:  finished
```

### Checking workflow logs

If our workflow has failed or in case we want to debug or investigate how our
workflow works, we may want to display the logs of our workflow. To do that
using REANA client we could use [logs](https://reana-client.readthedocs.io/en/maint-0.7/#reana-client-logs)
command. In our case the logs can be fetched with `get_workflow_logs` function
where we only need to specify workflow name and access token. Optionally, we
can add such parameters as a list of `steps` whose logs we are interested in
or `page` and `size` parameters to paginate the logs output if it gets too
verbose. For example, let's say that we want to quickly check the last 15 lines
of logs of the second `fitdata` step of our workflow. We can do that as follows:

```python
import json
from reana_client.api.client import get_workflow_logs

workflow_logs = get_workflow_logs(my_workflow_name, my_reana_token, ['fitdata'])
job_logs = json.loads(workflow_logs['logs'])['job_logs']
fitdata_logs = job_logs[next(iter(job_logs))]['logs']

for item in fitdata_logs.split('\n')[-15:]:
    print(item)
```

Output:

```python
ERR MATRIX APPROXIMATE
 PARAMETER  CORRELATION COEFFICIENTS
       NO.  GLOBAL      1      2      3      4      5
        1  0.00000   1.000  0.000  0.000  0.000  0.000
        2  0.00000   0.000  1.000  0.000  0.000  0.000
        3  0.00000   0.000  0.000  1.000  0.000  0.000
        4  0.00000   0.000  0.000  0.000  1.000  0.000
        5  0.00000   0.000  0.000  0.000  0.000  1.000
 ERR MATRIX APPROXIMATE
[#1] INFO:Minization -- RooMinimizer::optimizeConst: deactivating const optimization
[#1] INFO:Plotting -- RooAbsPdf::plotOn(model) directly selected PDF components: (bkg)
[#1] INFO:Plotting -- RooAbsPdf::plotOn(model) indirectly selected PDF components: ()
Info in <TCanvas::Print>: png file results/plot.png has been created
```

### Listing workspace files

Once the workflow is finished, we usually want to list all the output files which our workflow
produced. With REANA client it can be achieved by using
[ls](https://reana-client.readthedocs.io/en/maint-0.7/#reana-client-ls)
command. Similarly, it can be done in the following manner:

```python
from reana_client.api.client import list_files

list_files(my_workflow_name, my_reana_token)
```

Output:

```python
[
  {
    'last-modified': '2021-02-24T09:57:01',
    'name': 'code/gendata.C',
    'size': 1937,
  },
  {
    'last-modified': '2021-02-24T09:57:01',
    'name': 'code/fitdata.C',
    'size': 1648,
  },
  {
    'last-modified': '2021-02-24T09:57:52',
    'name': 'results/plot.png',
    'size': 15450,
  },
  {
    'last-modified': '2021-02-24T09:57:42',
    'name': 'results/data.root',
    'size': 154458,
  },
]
```

### Downloading outputs

After listing all the files we may want to download some of the results for inspection.
With REANA client we could use [download](https://reana-client.readthedocs.io/en/maint-0.7/#reana-client-download)
command. In this case to download a binary blob of a final plot which our
workflow produced all we need to do is to use `download_file` function:

```python
from reana_client.api.client import download_file

output_filename = 'results/plot.png'
file_binary_blob = download_file(
    my_workflow_name, output_filename, my_reana_token)
```

### Displaying output images

To display the output images of our workflow all we need to so is simply
execute the following lines:

```python
from PIL import Image
import io

image_stream = io.BytesIO(file_binary_blob)
img = Image.open(image_stream)
img.show()
```

Here you can see the final result:

![sign-up hidden](/images/reana-client-python-api-plot.png)

See also:
- [The reana-client Python API reference guide](https://reana-client.readthedocs.io/en/maint-0.7/#module-reana_client.api.client)
- [ROOT6 RooFit analysis example](https://github.com/reanahub/reana-demo-root6-roofit/)
- [Jupyter Notebook with example code](https://github.com/reanahub/blog.reana.io/examples/ipynb/reana-client-python-api.ipynb)
