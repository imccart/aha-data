# Meta --------------------------------------------------------------------
## Title:         Summary of Changes table
## Author:        Wonjun Choi
## Date Created:  9/9/2022
## Date Edited:   9/15/2022

## Dependency: numpy, pandas, tabula
#
# This code converts Change_of_summary pdf files into csv.
# This code only does minimal data cleaning. Extensive data cleaning is
# required after merging/building datasets.

# Issue found: ID is sometimes integer, sometimes float.
#              One ID was character: 653032B in 2011 file.
#
#              In some years merger&acquisition tables were
#              not in the form of dataframe. (discarded)
###########################################################################
import os
import numpy as np
import pandas as pd
from tabula.io import read_pdf

# Hardcoding part
import hardcoding
pagecontent_all = hardcoding.pagecontent_all

# functions
def combine_if_key_is_na_from_(where, table, key, columns, join_by=" "):
    """
    prototype code for fixing nonreg_add of 2007
    
    ID | ADDITION             ID |   ADDITION
    --------------            ------------------
    NA |     I           =>   NA | I AM IRON MAN
    NA |    AM                NA |      AM
    123|  IRON MAN            123|   IRON MAN
    
    Another code will copy ID from below and drop duplicated.
    
    This is a bad code... should have been absorbing the above...
    
    input
    =====
    where: "above" or "below"
    key: if key is NA, combine columns from {where} if there are multiple NA's in key in a row, find the first non-NA
    join_by: for join_by.join(["a", "b"])
    """
    t = table.copy()
    if type(columns) is str:
        columns = [columns]
    
    for col in columns:
        for row in range(len(t)):
#            print(row)
            if pd.isna(t.loc[row,key]) is True:
                combine_list = [t.loc[row,col]]
                if where is "below":
                    row2 = row
                    while pd.isna(t.loc[row2,key]) is True:
                        combine_list.append(t.loc[row2+1,col])
                        row2 = row2 + 1
                if where is "above":
                    row2 = row
                    while pd.isna(t.loc[row2,key]) is True:
                        combine_list.append(t.loc[row2-1,col])
                        print(t.loc[row2-1,col])
                        row2 = row2 - 1
                combine_list = [x if not pd.isna(x) else "" for x in combine_list]
                combine_list = [str(x) if type(x)==float else x for x in combine_list]
                if where is "above":
                    combine_list.reverse()
                joined_value = join_by.join(combine_list)
                t.loc[row,col] = joined_value
    return t

def fillna_from_(where, table, columns):
    """
    Fill na by copying from above/below.
    
    input
    =====
    where: "below", "above"
    table: pandas dataframe
    columns: list of strings
    """
    t = table.copy()
    while pd.isna(t[columns]).values.any():
        for row in range(len(t)):
            if pd.isna(t.loc[row]).values.any():
                for name in [columns]:
                    if where is "above":
                        t.loc[row,name] = t.loc[row-1,name]
                    elif where is "below":
                        t.loc[row,name] = t.loc[row+1,name]
    print("filled na")
    return t

# ====================================================================================
def tidy_reg_del(tab):
    t = tab.copy()
    if year in [2011]:
        t = combine_if_key_is_na_from_("below",t,'ID','NAME')
        t = fillna_from_('below',t,['ID','CITY','STATE','REASON FOR DELETION'])
    
    return t

def tidy_nonreg_del(tab):
    t = tab.copy()
    if year in [2007]:
        t = combine_if_key_is_na_from_("below", t, "ID", "REASON FOR DELETION")
        t = fillna_from_("below", t, ['ID','HOSPITAL NAME', 'CITY', 'STATE'])
        t = t.loc[~t.duplicated('ID')].reset_index().drop('index',axis=1)
    
    elif year in [2008]:
        col = 'REASON FOR DELETION'
        t[col] = t[col].apply(lambda text: text.replace("\r"," "))
    
    elif year in [2009]:
        t = combine_if_key_is_na_from_("below", t, "ID", ["REASON FOR DELETION","HOSPITAL NAME"])
        t = fillna_from_("below", t, ["ID", "CITY", "STATE"])
        t = t.loc[~t.duplicated('ID')].reset_index().drop('index',axis=1)
    
    return t

def tidy_nonreg_add(tab):
    """
    dd
    """
    t = tab.copy()
    if year in [2007]:  # year is a global variable. consider f(tab,year=year)
        t.columns = t.iloc[0]
        t = t[1:].reset_index(drop=True)
        t = combine_if_key_is_na_from_("below", t, "ID", "ADDITION")
        t = fillna_from_("below", t, ['ID','HOSPITAL NAME','CITY','STATE'])
        t = t.loc[~t.duplicated('ID')].reset_index().drop('index', axis=1)
        t.columns = ['ID', 'REASON FOR ADDITION', 'HOSPITAL NAME', 'CITY', 'STATE']
        
    elif year in [2008,2009]:
        t.columns = ['ID', 'REASON FOR ADDITION', 'HOSPITAL NAME', 'CITY', 'STATE']
        t['REASON FOR ADDITION'] = t['REASON FOR ADDITION'].apply(lambda x: x.replace("\r"," "))

        if year == 2009:
            t = combine_if_key_is_na_from_("below", t, "ID", "REASON FOR ADDITION")
            t = fillna_from_("below", t, ["ID", "CITY", "STATE", "HOSPITAL NAME"])
            t = t.loc[~t.duplicated('ID')].reset_index().drop('index',axis=1)
            t = t.drop(t[t.ID == "ID"].index)
            
    elif year in [2010]:
        t.columns = ['ID', 'REASON FOR ADDITION', 'HOSPITAL NAME', 'CITY', 'STATE']
        t = t[1:].reset_index(drop=True)
        def f(text):
            name = text.split('Newly Added')[-1].split('Status changed to')[-1]
            if name == 'nonregistered':
                reason, name = 'nonregistered', np.nan
                return reason, name
            elif len(name) == 0:
                reason, name = 'no thx', 'no thx'  # second page is ok...
                return reason, name
            else:
                reason = text.split(name)[0]
                name = name[1:]  # remove blank
                return reason, name
        for row in range(len(t)):
            reason, name = f(t.loc[row, 'REASON FOR ADDITION'])
            if not reason=='no thx':
                t.loc[row, 'REASON FOR ADDITION'] = reason
                t.loc[row, 'HOSPITAL NAME'] = name            
        t = combine_if_key_is_na_from_("above", t, "ID", "REASON FOR ADDITION")
        t = fillna_from_("above",t,["ID","HOSPITAL NAME", "CITY", "STATE"])
        
    return t
    
def tidy_merger(tab):
    t = tab.copy()
    
    if year in [2007]:
        t = t.loc[1:]

        t['Unnamed: 0'] = t['ID NAME'].apply(lambda idname: ' '.join(idname.split(' ')[1:]) if pd.isna(idname)==False else np.nan)
        t['ID NAME'] = t['ID NAME'].apply(lambda idname: idname.split(' ')[0] if pd.isna(idname)==False else np.nan)

        t['Unnamed: 1'] = t['MERGER MERGED NAME'].apply(lambda mmn: ' '.join(mmn.split(' ')[1:]) if pd.isna(mmn)==False else np.nan)
        t['MERGER MERGED NAME'] = t['MERGER MERGED NAME'].apply(lambda mmn: mmn.split(' ')[0] if pd.isna(mmn)==False else np.nan)

        t['MERGED STATE'] = t['MERGED CITY MERGED'].apply(lambda mcm: mcm.split(' ')[-1] if pd.isna(mcm)==False else np.nan)
        t['MERGED CITY MERGED'] = t['MERGED CITY MERGED'].apply(lambda mcm: ' '.join(mcm.split(' ')[:-1]) if pd.isna(mcm)==False else np.nan)

        t = t.rename(columns = {'ID NAME': 'ID', 'Unnamed: 0': 'NAME', 'MERGER MERGED NAME': 'MERGER RESULT ID',
                           'Unnamed: 1': 'MERGED NAME', 'MERGED CITY MERGED': 'MERGED CITY'})
        t = t.reset_index().drop(['index'],axis=1)

        t = fillna_from_("above", t, ['MERGER RESULT ID', 'MERGED NAME', 'MERGED CITY', 'MERGED STATE'])
        
    elif year in [2008]:
        t['Unnamed: 0'] = t['ID HOSPITAL NAME'].apply(lambda idname: ' '.join(idname.split(' ')[1:]) if pd.isna(idname)==False else np.nan)
        t['ID HOSPITAL NAME'] = t['ID HOSPITAL NAME'].apply(lambda idname: idname.split(' ')[0] if pd.isna(idname)==False else np.nan)
        
    elif year in [2009]:
        t.columns = [x.replace("\r"," ") for x in t.columns]
        t = fillna_from_("above", t, ['MERGER RESULT ID', 'MERGED NAME', 'MERGED CITY', 'MERGED STATE'])

    return t


##########################################################################
# make pdf tables into csv

dir_root = os.path.abspath(os.path.join(os.getcwd(), os.pardir))
outfile_base = os.path.join(dir_root, 'data','temp')

for year in range(2011,2012):
    file_pdf = os.path.join(dir_root,'data','input','AHA FY {}'.format(year), *hardcoding.filenames[year])
    tables = read_pdf(file_pdf, pages='all', multiple_tables=True)
    
    pagecontent = pagecontent_all[str(year)]
    
    table_reg_del = pd.concat([tables[page] for page in pagecontent["Reg Del"]], ignore_index=True)
    table_reg_del = table_reg_del.dropna()
    
    table_reg_add = pd.concat([tables[page] for page in pagecontent["Reg Add"]], ignore_index=True)
    table_reg_add = table_reg_add.dropna()
    
    table_nonreg_del = pd.concat([tidy_nonreg_del(tables[page]) for page in pagecontent["Nonreg Del"]], ignore_index=True)
    table_nonreg_del = table_nonreg_del.dropna()
    
    table_nonreg_add = pd.concat([tidy_nonreg_add(tables[page]) for page in pagecontent["Nonreg Add"]], ignore_index=True)    
    table_nonreg_add = table_nonreg_add.dropna()
    
    if year in [2008,2010]:
        print("Merger and Acquisitions {} table is a disaster".format(year))
        pass
    else:
        table_merger = pd.concat([tidy_merger(tables[page]) for page in pagecontent["Mergers and Acquisitions"]], ignore_index=True)
        table_merger.to_csv(os.path.join(outfile_base,'change_merger_{}.csv'.format(year)), header=True, index=False)
    
    # save csv
    table_reg_del.to_csv(os.path.join(outfile_base,'change_reg_del_{}.csv'.format(year)), header=True, index=False)
    table_reg_add.to_csv(os.path.join(outfile_base,'change_reg_add_{}.csv'.format(year)), header=True, index=False)
    table_nonreg_del.to_csv(os.path.join(outfile_base,'change_nonreg_del_{}.csv'.format(year)), header=True, index=False)
    table_nonreg_add.to_csv(os.path.join(outfile_base,'change_nonreg_add_{}.csv'.format(year)), header=True, index=False)