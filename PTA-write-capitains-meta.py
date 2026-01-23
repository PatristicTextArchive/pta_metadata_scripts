# %% [markdown]
# # Preparations

# %%
# adapted from https://github.com/Formulae-Litterae-Chartae/scripts/tree/master/corpus_transformation_scripts/Formulae
import glob
import subprocess
import shutil
from os import makedirs, environ, getcwd, remove, rename
import os.path
## workaround for https://github.com/quandyfactory/dicttoxml/issues/91:
import collections 
collections.Iterable = collections.abc.Iterable

# %% [markdown]
# ## constants

# %%
saxon_location = os.path.expanduser('~/Dokumente/projekte/pta_collator/vendor/saxon9he.jar')
metadata_transformation_xslt = os.path.expanduser('~/Dokumente/projekte/pta-corpus-transformation-scripts/create_cts_files_new.xsl')
destination_folder = os.path.expanduser('~/Dokumente/projekte/pta_data/data')
analyzed_folder = os.path.expanduser('~/Dokumente/projekte/pta_data/analyzed')
xml_dir = os.path.expanduser('~/Dokumente/projekte/pta_data/data/*/*/pta*.xml') #os.path.expanduser('~\Downloads\pta_data\data\*\*\pta*.xml')
xml_paths = glob.glob(xml_dir)
temp_files = []

# %% [markdown]
# # Works

# %%
## Versionierung eintragen
from dicttoxml import dicttoxml
from xml.dom.minidom import parseString
gitliste = []
for source in sorted(xml_paths, reverse=False):
    label = {}
    corpus_name = os.path.split(source)[1].split(".")[0]
    work_name = os.path.split(source)[1].split(".")[1]
    file_name = os.path.split(source)[1]
    os.path.expanduser('~/Dokumente/projekte/pta_data/'))
    label["urn"] = "urn:cts:pta:"+file_name.rsplit('.', 1)[0]
    try:
        git = subprocess.check_output(['git', 'log', '--follow', '-1', "--pretty=format:%H,%ad", "--date=short", "data/"+corpus_name+"/"+work_name+"/"+file_name]).decode("utf-8").split(",")
        label["hash"] = git[0]
        label["date"] = git[1]
    except:
        label["hash"] = ""
        label["date"] = ""       
    gitliste.append(label)
xml = dicttoxml(gitliste)
dom = parseString(xml)
with open(os.path.expanduser('~/Dokumente/projekte/pta-corpus-transformation-scripts/git-commit_liste.xml'), 'w') as file_open:
    file_open.write(dom.toprettyxml())

# %%
def sortkey(source):
    if "deu" in os.path.split(source)[1]:
        key = 0
    elif "eng" in os.path.split(source)[1]:
        key = 1
    elif "syc" in os.path.split(source)[1]:
        key = 2
    elif "Ms" in os.path.split(source)[1]:
        key = 3
    elif "com" in os.path.split(source)[1]:
        key = 4
    elif "rum" in os.path.split(source)[1]:
        key = 5
    elif "xcl" in os.path.split(source)[1]:
        key = 6
    elif "lat" in os.path.split(source)[1]:
        key = 7
    else:
        key= 8
    return key

# %%
for source in sorted(xml_paths, key=sortkey, reverse=False):
    corpus_name = os.path.split(source)[1].split(".")[0]
    work_name = os.path.split(source)[1].split(".")[1]
    file_name = os.path.split(source)[1]
    print(file_name)
    #if not os.path.isdir(destination_folder+"/data/"+corpus_name+"/"+work_name):
    #    os.makedirs(destination_folder+"/data/"+corpus_name+"/"+work_name)
    #shutil.copy(source,destination_folder+"/data/"+corpus_name+"/"+work_name)
    subprocess.run([r'/usr/bin/java', '-jar',  saxon_location, '{}'.format(source), metadata_transformation_xslt, '-o:{base_folder}/{corpus}/{work}/__cts__.xml'.format(base_folder=destination_folder, corpus=corpus_name, work=work_name)])
    #shutil.copy(destination_folder+"/"+corpus_name+"/"+work_name+"/__cts__.xml",analyzed_folder+"/"+corpus_name+"/"+work_name+"/__cts__.xml")


