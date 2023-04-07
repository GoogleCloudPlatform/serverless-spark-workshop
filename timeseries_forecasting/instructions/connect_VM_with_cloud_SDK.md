# About

This module will focus on installing Cloud SDK to your local machine and connect to VM
<br><br>


#### 1. Download Cloud SDK
Download GCloud SDK Package https://cloud.google.com/sdk/docs/downloads-versioned-archives#installation_instructions
<br>

#### 2. (MAC) Navigate to your Cloud SDK Package and unpack it.
Open your terminal and enter this command. Replace google-cloud-sdk-290.0.0-darwin-x86_64.tar.gz with the version you downloaded
<br>
```
cd ~/Downloads
mv google-cloud-sdk-290.0.0-darwin-x86_64.tar.gz ~/
cd ~/
```
<br>
Unpacking the <b>tar</b> file
<br>

```
tar xopf google-cloud-sdk-290.0.0-darwin-x86_64.tar.gz
rm google-cloud-sdk-290.0.0-darwin-x86_64.tar.gz
```
<br>
Install <b>gcloud</b> on your <b>PATH</b>
<br>

```
cd google-cloud-sdk
./install.sh
```
<br>
You should see a warning pop up relate to modify profile to update your $PATH and enable shell command.
<br>
<kbd>
<img src=/images/update_path.png />
</kbd>
<br>
Type <b>Y</b> and hit <b>return/enter</b>.
<br>
This will make it easier to run gcloud anywhere in terminal. It is recommend to leave it blank by default.<br>
Hit <b>return</b> to accept the default.
<br>
<kbd>
<img src=/images/path_name.png />
</kbd>
<br>


#### 2. (Window) Navigate to your Cloud SDK Package and unpack it.
Replace google-cloud-sdk-290.0.0-windows-x86_64.zip with the version you downloaded
<br>

```
cd ~/Downloads
mv google-cloud-sdk-290.0.0-windows-x86_64.zip ~/
cd ~/
```
<br>
Unpacking the <b>zip</b> file
<br>

```
Expand-Archive google-cloud-sdk-290.0.0-windows-x86_64.zip .
```
<br>
Remove the archive:
<br>

```
rm google-cloud-sdk-290.0.0-windows-x86_64.zip
```
<br>
Install:

```
cd google-cloud-sdk
.\install.bat
```
<br>
You should see something similar to this:
<br>

```
Welcome to the Google Cloud SDK!

To help improve the quality of this product, we collect anonymized usage data
and anonymized stacktraces when crashes are encountered; additional information
is available at <https://cloud.google.com/sdk/usage-statistics>. This data is
handled in accordance with our privacy policy
<https://policies.google.com/privacy>. You may choose to opt in this
collection now (by choosing 'Y' at the below prompt), or at any time in the
future by running the following command:

    gcloud config set disable_usage_reporting false

Do you want to help improve the Google Cloud SDK (y/N)?
```
<br>
Type <b>y</b> or <b>n</b> and press <b>enter</b> to continue.
<br>
It will ask you to update your PATH. It is recommended to run gcloud anywhere in powershell by press <b>y</b>.
<br>

```
Update %PATH% to include Cloud SDK binaries? (Y/n)?  .
Please enter 'y' or 'n':
```

<br>

#### 3. Update glcoud
Open your terminal and type this command
<br>

```
gcloud components update
```
<br>

#### 4. Login on the Command Line
You must login to use Cloud SDK. Type this command to login.
<br>

```
gcloud auth login
```
<br>
Note: This will open a web broswer and ask you to login to Google. Make sure you accept that <b>Google Cloud SDK wants to access your Google Account</b>
<br>

#### 5. Set your project in the terminal
Type this command.
<br>

```
gcloud config set project <project_id>>
```
<br>

#### 6. Connect to your VM
You can connect by typing this command:
<br>

```
gcloud compute ssh --project=<project_id> --zone=<region_zone> <vm_name>
```
Example: gcloud compute ssh --project=project12345 --zone=us-central1-a vm_test
<br>
