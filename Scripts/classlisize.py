import sys
import os
import classla
import re
emptyline_re = re.compile('\n\s+\n')
ne_cat_re = re.compile(r'NER=(.+?)[|\n]')
nlp = classla.Pipeline('sl',processors='tokenize,ner,pos,lemma,depparse',use_gpu=True)
import xml.etree.ElementTree as ET
from xml.dom import minidom
ET.register_namespace('','http://www.tei-c.org/ns/1.0')
from copy import deepcopy

def generate_tei(seq,parent):
    seq=deepcopy(seq)
    attrib=deepcopy(parent.attrib)
    parent.clear()
    parent.attrib=attrib
    #print(attrib)
    seg_id=attrib['{http://www.w3.org/XML/1998/namespace}id']
    #return
    #print(parent.tostring())
    #print(seq)
    text=''
    for e in seq:
        if isinstance(e,str):
            text+=e
    #print(text)
    doc=nlp(text)
    seq_idx=0
    str_idx=0
    while not isinstance(seq[seq_idx],str):
        parent.append(seq[seq_idx])
        seq_idx+=1
        if seq_idx==len(seq):
            return
    for sidx,sentence in enumerate(doc.conll_file.conll_as_string().strip().split('\n\n')):
        #print(sentence)
        s_id=seg_id+'.'+str(sidx+1)
        s = ET.Element('s',attrib={'xml:id':s_id})
        parent.append(s)
        ne_cat='O'
        parent_s = s
        tokens = sentence.split('\n')
        dependencies=[]
        for tidx,token in enumerate(tokens):
            #print(ET.tostring(parent))
            if token.startswith('#'):
                continue
            token=token.split('\t')
            t_id=s_id+'.'+token[0]
            if token[6]=='0':
                dependencies.append(('ud-syn:'+token[7],'#'+s_id+' #'+t_id))
            else:
                dependencies.append(('ud-syn:'+token[7],'#'+s_id+'.'+token[6]+' #'+t_id))
            new_str_idx = seq[seq_idx].find(token[1],str_idx)
            while new_str_idx == -1:
                seq_idx+=1
                #print("pre",seq_idx,seq)
                while not isinstance(seq[seq_idx],str):
                    #print("in",seq_idx,seq)
                    if tidx+1 == len(tokens):
                        parent.append(seq[seq_idx])
                    else:
                        s.append(seq[seq_idx])
                    seq_idx+=1
                    if seq_idx==len(seq):
                        return
                str_idx=0
                new_str_idx = seq[seq_idx].find(token[1],str_idx)
                #print(new_str_idx,token[1],seq[seq_idx])
            str_idx = new_str_idx+len(token[1])
            #print(new_str_idx,token[1],seq[seq_idx])
            ner = token[9].split('|')[0][4:].upper()
            if ner.endswith('DERIV-PER'):
                ner='O'
            if ner.startswith('B-'):
                if ne_cat!='O':
                    s = parent_s
                name = ET.Element('name')
                name.attrib['type'] = {'B-PER':'PER','B-LOC':'LOC','B-ORG':'ORG','B-MISC':'MISC'}[ner]
                s.append(name)
                s = name
                ne_cat = ner
            elif ner=='O' and ne_cat!='O':
                s = parent_s
                ne_cat = ner
            if token[3]=='PUNCT':
                pc=ET.Element('pc',attrib={'xml:id':t_id})
                pc.attrib['msd']='UPosTag=PUNCT'
                pc.attrib['ana']='mte:'+token[4]
                pc.text=token[1]
                if 'SpaceAfter=No' in token[9]:
                    pc.attrib['join']='right'
                s.append(pc)
            else:
                w=ET.Element('w',attrib={'xml:id':t_id})
                w.attrib['msd']='UPosTag='+token[3]
                if token[5]!='_':
                    w.attrib['msd']+='|'+token[5]
                w.attrib['ana']='mte:'+token[4]
                w.attrib['lemma']=token[2]
                w.text=token[1]
                if 'SpaceAfter=No' in token[9]:
                    w.attrib['join']='right'
                s.append(w)
        linkGrp=ET.Element('linkGrp',attrib={'type':'UD-SYN','targFunc':'head argument'})
        parent_s.append(linkGrp)
        for dep in dependencies:
            linkGrp.append(ET.Element('link',attrib={'ana':dep[0],'target':dep[1]}))
    seq_idx+=1
    while seq_idx!=len(seq):
        parent.append(seq[seq_idx])
        seq_idx+=1

for file in os.listdir('ParlaMint-SI/'):
    if not file.endswith('.xml') or 'classla' in file:
        continue
    file='ParlaMint-SI/'+file
    print(file)
    tree = ET.parse(file)
    root = tree.getroot()
    i=0

    for seg in root.iter('{http://www.tei-c.org/ns/1.0}seg'):
        i+=1
        seg_seq=[]
        if seg.text!=None:
            seg_seq.append(seg.text)
        for i,e in enumerate(seg):
            tail=e.tail
            e.tail=None
            seg_seq.append(e)
            if tail!=None and tail.strip()!='':
                if len(seg_seq)>1:
                    if seg_seq[-2][-1]!=' ' and tail[0]!=' ':
                        tail=' '+tail
                seg_seq.append(tail)
        generate_tei(seg_seq,seg)

    xmlstr = minidom.parseString(ET.tostring(root)).toprettyxml(indent="   ")
    xmlstr = emptyline_re.sub('\n',xmlstr)
    open(file[:-4]+'.classla.xml','w').write(xmlstr)
