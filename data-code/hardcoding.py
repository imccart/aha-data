# Meta --------------------------------------------------------------------
## Title:         Summary of Changes table
## Author:        Wonjun Choi
## Date Created:  9/9/2022
## Date Edited:   Oct/11/2022

# -------------------------------------------------------------------------

# filenames
filenames = {2007: ['DOC','2007 Summary of Changes.pdf'],
             2008: ['DOC','2008 Summary of Changes.pdf'],
             2009: ['Doc','2009_Summary_of_Changes.pdf'],
             2010: ['DOCUMENTATION', '2010_Summary_of_Changes.pdf'],
             2011: ['DOCUMENTATION', '2011_Summary_of_Changes.pdf'],
             2012: ['DOCUMENTATION', '2012_Summary_of_Changes.pdf'],
             2013: ['DOCUMENTATION', '2013_Summary_of_Changes.pdf'],
             2014: ['DOCUMENTATION', '2014_Summary_of_Changes.pdf'],
             2015: ['DOCUMENTATION', '2015_Summary_of_Changes.pdf'],
             2016: ['2016_Summary_of_Changes.pdf'],
             2017: ['2017_Summary_of_Changes.pdf'],
             2018: ['2018_Summary_of_Changes.pdf'],
             2019: ['2019_Summary_of_Changes.pdf']} 

# list of pages to be read by tabula.read_pdf


# table info of each year
pagecontent_2007 = {"Reg Del": [1,2], "Reg Add": [3], "Nonreg Del": [5,6], "Nonreg Add": [7,8,9], "Mergers and Acquisitions": [10]}
pagecontent_2008 = {"Reg Del": [1], "Reg Add": [2,3,4], "Nonreg Del": [6,7,8,9,10], "Nonreg Add": [11,12,13,14,15,16], "Mergers and Acquisitions": [17,18]}
pagecontent_2009 = {"Reg Del": [1,2], "Reg Add": [3,4], "Nonreg Del": [6,7,8], "Nonreg Add": [9,10,11], "Mergers and Acquisitions": [12]}
pagecontent_2010 = {"Reg Del": [1,2], "Reg Add": [3], "Nonreg Del": [5], "Nonreg Add": [6,7], "Mergers and Acquisitions": [8,9]}
pagecontent_2011 = {"Reg Del": [1,2], "Reg Add": [3,4], "Nonreg Del": [6,7], "Nonreg Add": [8,9], "Mergers and Acquisitions": [10]}
pagecontent_2012 = {"Reg Del": [1,2,3,4], "Reg Add": [5,6,7,8,9],
                    "Nonreg Del": [11,12,13,14,15], "Nonreg Add": [16,17],
                    "Mergers and Acquisitions": []}
pagecontent_2013 = {"Reg Del": [1,2,3], "Reg Add": [4], "Nonreg Del": [6], "Nonreg Add": [7,8], "Mergers and Acquisitions": []}
pagecontent_2014 = {"Reg Del": [1,2,3,4], "Reg Add": [5], "Nonreg Del": [7,8], "Nonreg Add": [9], "Mergers and Acquisitions": []}
pagecontent_2015 = {"Reg Del": [1,2], "Reg Add": [], "Nonreg Del": [4], "Nonreg Add": [5,6], "Mergers and Acquisitions": []}
pagecontent_2016 = {"Reg Del": [1], "Reg Add": [], "Nonreg Del": [2], "Nonreg Add": [4,3], "Mergers and Acquisitions": []}
pagecontent_2017 = {"Reg Del": [2,3], "Reg Add": [4], "Nonreg Del": [], "Nonreg Add": [], "Mergers and Acquisitions": []}
pagecontent_2018 = {"Reg Del": [1,2,3,4], "Reg Add": [5], "Nonreg Del": [], "Nonreg Add": [], "Mergers and Acquisitions": []}
pagecontent_2019 = {"Reg Del": [1,2,3,4,5,6], "Reg Add": [7,8,9], "Nonreg Del": [], "Nonreg Add": [], "Mergers and Acquisitions": []}

pagecontent_all = {"2007": pagecontent_2007, "2008": pagecontent_2008, "2009": pagecontent_2009,
                  "2010": pagecontent_2010, "2011": pagecontent_2011, "2012": pagecontent_2012,
                  "2013": pagecontent_2013, "2014": pagecontent_2014, "2015": pagecontent_2015,
                  "2016": pagecontent_2016, "2017": pagecontent_2017, "2018": pagecontent_2018,
                  "2019": pagecontent_2019}