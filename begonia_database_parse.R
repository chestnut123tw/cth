## get the Begonia name list from Southeast asian begonia database
  temp.scan.blist=scan(file = 'begonialist_database.txt',what = 'c',sep='\n',encoding = 'UTF-8')
  temp2.blist=unlist(strsplit(temp.scan.blist,'\"'))
  blist.list=temp2.blist[grep('["|"]',temp2.blist)]
  blist.list=gsub(' ','+',blist.list)
  blist.list=gsub('["|"]',"%7C",blist.list)

## concatenate as a species html
  pre.http="http://elmer.rbge.org.uk/Begonia/specimens/begonia.php?pt_member%2Bof=&pt2_member%2Bof=&exprcont%3Aname%2Bfor%2Bdisplay=&exprbegin%3ACollector%2Bnumber=&nt_member%2Bof="
  suf.http="&d_current=true&cfg=begonia%2Fbegoniaspecs.cfg"
#   &startrow=11
  
  begonia.http=paste(pre.http,blist.list,suf.http,sep='')
  
rm(list=c('blist.list','pre.http','suf.http','temp.scan.blist','temp2.blist'))

## get all database html by every page
  begonia.database.http=c()
    for(j in 1:length(begonia.http)){
    ## get the count of specimen each species
    ind.html=getURL(begonia.http[j])
    ind.html=htmlParse(ind.html,asText = T)
    
    ind.parse=xpathApply(ind.html,'//table//tr//td')
    ## assume page and count information of the species at ind.parse[7]
    logic.page.row=grepl('Page\\s+\\d+\\s+of\\s+\\d',
                        xmlValue(ind.parse[7][[1]]))
    if(logic.page.row){
    #   ind.page=gsub('.+Page\\s+\\d\\s+\\w+\\s+(\\d).+','\\1',xmlValue(ind.parse[7][[1]]))
      ind.count=as.numeric(
        gsub('.+Hits\\s+\\d+\\s+\\w+\\s+\\d+\\s+\\w+\\s+(\\d+).+','\\1',xmlValue(ind.parse[7][[1]]))
      )
    } else{i=1;## if not at ind.parse[7], do search from ind.parse
      while(i<=length(ind.parse)){print(i);
        temp.ind.parse=xmlValue(ind.parse[i][[1]])  
        logic.page.row=grepl('Page\\s+\\d+\\s+of\\s+\\d',
                             xmlValue(ind.parse[i][[1]]))
        if(logic.page.row){
    #       ind.page=gsub('.+Page\\s+\\d\\s+\\w+\\s+(\\d).+','\\1',xmlValue(ind.parse[7][[1]]))
          ind.count=as.numeric(
            gsub('.+Hits\\s+\\d+\\s+\\w+\\s+\\d+\\s+\\w+\\s+(\\d+).+','\\1',xmlValue(ind.parse[7][[1]]))
          )
        break
      }
      i=i+1
      }
    }
  
  ind.eachpage.http=paste(begonia.http[j],"&startrow=",seq(from=1,to=ind.count,by=10),sep='')
  
  begonia.database.http=c(begonia.database.http,ind.eachpage.http)
    }
  
  
  
  ## write out to file:test.txt
  write.table(begonia.database.http,'r:/test.txt',sep='\n',row.names=F,col.names=F,fileEncoding = 'UTF-8')
  
  ## input file:test.txt
  