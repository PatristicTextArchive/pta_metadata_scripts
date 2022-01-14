#!/usr/bin/env python
# coding: utf-8

# # Preparations

# In[1]:


# adapted from https://github.com/Formulae-Litterae-Chartae/scripts/tree/master/corpus_transformation_scripts/Formulae
import glob
import subprocess
import shutil
from os import makedirs, environ, getcwd, remove, rename
import os.path
import subprocess



# ## constants

# In[2]:


home_dir = environ.get('HOME', '')
saxon_location = '/usr/share/java/saxon/saxon9ee.jar'
metadata_transformation_xslt = home_dir + '/Dokumente/projekte/pta-corpus-transformation-scripts/create_cts_files_new.xsl'
destination_folder = getcwd() # The base folder where the corpus folder structure should be built
xml_dir = os.path.expanduser('~/Dokumente/projekte/pta_data/data/*/*/pta*.xml')
xml_paths = glob.glob(xml_dir)
temp_files = []


# # Works

# In[3]:


## Versionierung eintragen
from dicttoxml import dicttoxml
from xml.dom.minidom import parseString
gitliste = []
for source in sorted(xml_paths, reverse=False):
    label = {}
    corpus_name = os.path.split(source)[1].split(".")[0]
    work_name = os.path.split(source)[1].split(".")[1]
    file_name = os.path.split(source)[1]
    os.chdir(os.path.expanduser('~/Dokumente/projekte/pta_data/'))
    label["urn"] = "urn:cts:pta:"+file_name.rsplit('.', 1)[0]
    try:
        git = subprocess.check_output(['git', 'log', '-1', '--follow', "--pretty=format:%H,%ad", "--date=short", "data/"+corpus_name+"/"+work_name+"/"+file_name]).decode("utf-8").split(",")
        label["hash"] = git[0]
        label["date"] = git[1]
    except:
        label["hash"] = ""
        label["date"] = ""       
    gitliste.append(label)
xml = dicttoxml(gitliste)
dom = parseString(xml)
with open(home_dir + '/Dokumente/projekte/pta-corpus-transformation-scripts/git-commit_liste.xml', 'w') as file_open:
    file_open.write(dom.toprettyxml())


# In[4]:


def sortkey(source):
    if "deu" in os.path.split(source)[1]:
        key = 0
    elif "eng" in os.path.split(source)[1]:
        key = 1
    elif "rum" in os.path.split(source)[1]:
        key = 2
    elif "Ms" in os.path.split(source)[1]:
        key = 3
    else:
        key= 4
    return key


# In[5]:


for source in sorted(xml_paths, key=sortkey, reverse=False):
    corpus_name = os.path.split(source)[1].split(".")[0]
    work_name = os.path.split(source)[1].split(".")[1]
    file_name = os.path.split(source)[1]
    if not os.path.isdir(destination_folder+"/data/"+corpus_name+"/"+work_name):
        os.makedirs(destination_folder+"/data/"+corpus_name+"/"+work_name)
    shutil.copy(source,destination_folder+"/data/"+corpus_name+"/"+work_name)
    subprocess.run(['java', '-jar',  saxon_location, '{}'.format(source), metadata_transformation_xslt, '-o:{base_folder}/data/{corpus}/{work}/__cts__.xml'.format(base_folder=destination_folder, corpus=corpus_name, work=work_name)])

