TO DO:
  1. Figure out Memo 1.
  2. Make Summary of Changes.pdf into table (python/R)
  3. Work on 2007 and compare it to Cooper-et-al.

Do 2 first, research or email Ian for 1.

Memo:
  1. Seems Cooper et al. pooled `sysid==2` into one unit somehow...?????????
  2. All the files are the same (csv, sas etc)
  3. codebook, etc are in `DOC` directory.
  4. In change of merger file, the 'merger and acquisition' table is redundant more or less.
  5. Wide panel or Long panel? Maybe doesnt matter. Make each year seperately then make both.
  6. What is register? Doesn't matter. Add is add, del is del. It seems that AHA manage reg/nonreg separately, but it seems there is no difference in our end?

Outcome:  

Merge
  1. In 2008, WJH merged KYH
      id |  year  | name | acquisition(merger) | merged::binary | open::binary | closed/merged
      ----------
      1  |  2007  | WJH  |           0         |        0       |     0        |       0
      2  |  2007  | KYH  |           0         |        0       |     0        |       0
      1  |  2008  | WJH  |           1         |        0       |     0        |       0
      (2)| (2008) |(KYH) |          (0)        |       (1)      |     0        |       0
      The last row does not exist? I guess.

  2. In 2008, WJH and KYH formed RAH
      id | year | name | acquisition(merger) | merged::binary | open::binary | closed/merged
      ----------
      1  | 2008 | WJH  |           1         |        0       |     1*       |       1
      2  | 2008 | KYH  |           0         |        1       |     0        |       1
      3  | 2008 | RAH  |   is this merger?   |        0       | is this open?|       0

  3. In 2009, RAH merged newRA and changed its name to ThreeRAH (isn't this case 2?)

Demerge  
   3. In 2009, KYH demerged from RAH
       id | year | name | acquisition(merger) | merged::binary | open::binary | closed/merged
       ----------
       1  | 2009 | RAH  |           0         |        0       |     1*       |       1
       2  | 2009 | KYH  |           0         |        1       |     0        |       1
       3  | 2007 | RAH  |   is this merger?   |        0       | is this open?|       0


ETC
  3. In 2007, WJH changed its name to WJMC
      id | year | name | acquisition(merger) | merged::binary | open::binary | closed/merged
      ----------
      1  | 2007 | WJH  |           0         |        0       |     0        |       1
      2  | 2007 | WJMC |           0         |        0       |     1        |       0




*open==2007 if open before or in 2007
