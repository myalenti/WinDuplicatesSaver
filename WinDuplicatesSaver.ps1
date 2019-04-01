


$sourcePath = "E:\Backup\Stacey\"
$destPrefix = "F:\rescue"
$extensions = "*.pdf","*.jpg","*.doc","*.docx","*.xls","*.gif","*.mp4","*.xlsx","*.csv","*.zip","*.ppt","*.pptx"
$baseToReplace = "E:"


# -literalPath is needed for files and directories with meta-characters and -Filter should be used instead of -include
# as -include appears to be buggy and requires an * in the path which -literalPath does not support.
$files = get-childitem -literalPath $sourcePath -Filter $extensions -recurse -Force | sort-object {$_.Name}

#initialize an empty array
$validFiles = @()
$previous = ""
#write-output ("File Count: " + $files.Count + " validFiles count: " + $validFiles.count )


function getDestination( $item )
{
    $destination = $item.fullName.replace( $basetoReplace, $destPrefix)
    return $destination
       
}

foreach( $file in $files){
# if previous is empty assign it
# if previous is identical compare the date
    #if the date is newer replace previous
# if previous is not identical send to array and set new previous
    
    if ( $previous -eq "")
    {
        $previous = $file
 #       write-output ( "current value of previous: " + $previous.Name)
    }

    if ($previous.Name  -eq  $file.Name){
        if ($previous.CreationTime -lt $file.CreationTime)
        {
  #          write-output( "Replacing Previous")
            $previous = $file
        }
    }
    if ( $previous.Name -ne $file.Name)
    {
   #     write-output("found new file")
        #send to array
        $validFiles += $previous
    #    Write-Output "should write to array"
        #copy file to rescue location
        $destination = getDestination($previous)
     #   Write-output $destination
        try
        {
            Copy-Item $previous.FullName  -Destination $destination
        }catch{
            try {
            Write-Output ("Directory did not exist, retrying with touch : " + $previous.FullName + " to " + $destination)
            New-Item -ItemType File -Path $destination -Force
            Copy-Item $previous.FullName  -Destination $destination -Force
            }catch{
                try{
                    Write-Output ("Writing to emergency scavenge directory : " + $previous.FullName + " to " + $destination)
                    $destination = $destPrefix + "\emergency\" + $previous.Name
                    New-Item -ItemType File -Path $destination -Force
                    Copy-Item $previous.FullName  -Destination $destination -Force

                }catch{
                    Write-output ("Permanent Write failure: " + $previous.Fullname)
                    continue
                }
            }
        }
        #set previous to new file
        $previous = $file
    }
}

write-output ("File Count: " + $files.Count + " validFiles count: " + $validFiles.count )
