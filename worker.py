from urllib.request import urlopen
import datetime
from azure.storage.blob import BlockBlobService, PublicAccess

now = datetime.datetime.now()

# Setting up credentials to access Azure storage account
block_blob_service = BlockBlobService(account_name='name', account_key='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
# Creating the timestamp for blob-container name
date_string = str(now.month) + str(now.day) + str(now.hour) + str(now.minute)
container_name = 'name' + date_string
# Creating blob-container inside the storage account
block_blob_service.create_container(container_name)
block_blob_service.set_container_acl(container_name, public_access=PublicAccess.Container)

base_page="https://www.docker.com/"
html = urlopen(base_page).read()
file_name='SC'+ date_string +".html"

with open(file_name, 'wb') as fh:
    fh.write(html)
print('Uploading to blob')
block_blob_service.create_blob_from_path(container_name, file_name, file_name)