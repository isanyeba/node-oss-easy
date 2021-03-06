require 'mocha'
should = require('chai').should()
ossEasy = require "../oss-easy"
fs = require "fs"
path = require "path"
config = require "./config"


STRING_CONTENT_FOR_TESTING = "hahaaha just a piece of data"

STRING_CONTENT_FOR_TESTING2 = "222 just a piece of data 222"

ossOptions =
  accessKeyId : config.accessKeyId
  accessKeySecret : config.accessKeySecret
  bucket : config.bucket
  #uploaderHeaders :
    #"Content-disposition" : "attachment;filename=whatever.gif"

oss = new ossEasy(ossOptions)

FILE_NAMES= [
  "#{Date.now()}-t1",
  "#{Date.now()}-t2",
  "#{Date.now()}-t3",
  "#{Date.now()}-t4"]
#FILE_NAMES= [
#  "1234567-t1",
#  "1234567-t2",
#  "1234567-t3",
#  "1234567-t4"]
#
describe "testing oss", (done)->

  @timeout(10000)

  it "writeFile and readFile", (done)->
    filename = "just/a/test.json"
    oss.writeFile filename, STRING_CONTENT_FOR_TESTING, (err)->
      should.not.exist(err)
      oss.readFile filename, 'utf8', (err, data)->
        console.log "[readFile] data:#{data}"
        data.should.equal STRING_CONTENT_FOR_TESTING
        done()


  it "uploadFile and downloadFile", (done)->
    pathToTempFile = "/tmp/#{Date.now()}"
    pathToTempFile2 = "/tmp/#{Date.now()}-back"
    fs.writeFileSync pathToTempFile, STRING_CONTENT_FOR_TESTING2

    filename = "test-file-upload-download"

    oss.uploadFile pathToTempFile, filename, (err) ->
      should.not.exist(err)
      oss.downloadFile filename, pathToTempFile2, (err) ->
        should.not.exist(err)
        fs.readFileSync(pathToTempFile2, 'utf8').should.equal(fs.readFileSync(pathToTempFile, 'utf8'))
        done()


  it "uploadFile file with custom header", (done)->
    pathToTempFile = "/tmp/#{Date.now()}-custom-header"
    fs.writeFileSync pathToTempFile, STRING_CONTENT_FOR_TESTING2

    filename = "test-file-upload-custom-header"

    oss.uploadFile pathToTempFile, filename,
      "Cache-Control": "max-age=5"
      "Expires" : Date.now() + 300000
    , (err) ->
      should.not.exist(err)
      done()
      return



  it "transport file", (done)->
    url = "http://asset-image.weixinzhongxin.com/temp_img_resize/2.pic_hd.jpg"
    arr = url.split '/'
    remoteFilePath = "oss-easy-test/transport/#{arr[arr.length - 1]}"
    pathToTempFile2 = "/tmp/#{Date.now()}-back"
    oss.uploadFile url, remoteFilePath, (err)->
      should.not.exist(err)
      oss.downloadFile remoteFilePath, pathToTempFile2, (err, data)->
        should.not.exist(err)
        done()

  it "uploadFile multiple files", (done)->
    tasks = {}
    for i in [0...4] by 1
      tasks["/tmp/#{FILE_NAMES[i]}"] = "test/upload/multiple/files-#{i}"
      fs.writeFileSync "/tmp/#{FILE_NAMES[i]}", "#{STRING_CONTENT_FOR_TESTING2}-#{i}"
    oss.uploadFiles tasks, (err)->
      should.not.exist(err)
      done()
      return
    return

  it "copy file", (done) ->
    sourceFilePath =  "test/upload/multiple/files-0"
    destinationFilePath = "test/upload/multiple/files-00"
    oss.copyFile sourceFilePath, destinationFilePath, (err) ->
      should.not.exist(err)
      done()
      return
    return

  it "copy multiple file", (done) ->
    tasks = {}
    for i in [0...4] by 1
      sourceFilePath =  "test/upload/multiple/files-#{i}"
      destinationFilePath = "test/upload/multiple/files-1#{i}"
      tasks[sourceFilePath] = destinationFilePath
    oss.copyFiles tasks,(err) ->
      should.not.exist(err)
      done()
      return
    return

  #it "capy folder", (done) ->
    #oss.copyFolder "test/upload/multiple/","test/upload/multiple2/", (err) ->
      #should.not.exist err
      #done()
      #return
    #return


  #it "download multiple files", (done)->
    #tasks = {}
    #for i in [0...4] by 1
      ##tasks["test/upload/multiple/files-#{i}"] = "/tmp/download-#{FILE_NAMES[i]}"
      #tasks["test/upload/multiple2/files-#{i}"] = "/tmp/download-#{FILE_NAMES[i]}"
    #oss.downloadFiles tasks, (err)->
      #should.not.exist(err)
      #for i in [0...4] by 1
        #fs.readFileSync("/tmp/download-#{FILE_NAMES[i]}", 'utf8').should.equal(fs.readFileSync("/tmp/#{FILE_NAMES[i]}", 'utf8'))
      #done()
      #return

  #it "delete file", (done)->
    #remoteFilePath = "just/a/test"
    #oss.deleteFile remoteFilePath, (err)->
      #should.not.exist(err)
      #done()
      #return
    #return


  #it "delete a folder", (done)->
    #oss.deleteFolder "test/upload/multiple/", (err)->
      #oss.deleteFolder "test/upload/multiple2/", (err)->
        #should.not.exist(err)
        #done()
        #return
      #return
    #return


