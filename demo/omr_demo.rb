require 'aspose_omr_cloud'
require 'aspose_storage_cloud'
require 'uri'
require 'fileutils'
require "base64"

##
# @summary Storage helper class
#
class Storage
  ##
  # Storage constructor.
  # @param [string]    app_key Application Key
  # @param [string]    app_sid Application SID
  # @param [string]    base_path   Base Path URL
  # @param [bool]      debugging   true to verbose output
  #
  def initialize(app_key, app_sid, base_path, debugging = false)
    uri = URI.parse(base_path)

    AsposeStorageCloud.configure do |config|
      config.api_key['api_key'] = app_key
      config.api_key['app_sid'] = app_sid
      config.scheme = uri.scheme
      if uri.port.to_s.empty?
        config.host = uri.host
      else
        config.host = "#{uri.host}:#{uri.port}"
      end
      config.api_version = uri.path
      config.debugging = debugging
    end
    @storage_api = AsposeStorageCloud::StorageApi.new
  end

  ##
  # @summary Uploads file to storage
  # @param [string]    local_file_path  Local file path
  # @param [string]    remote_file_path Remote file path
  #
  def upload_file(local_file_path, remote_file_path = '')
    if local_file_path.to_s.empty?
      raise ArgumentError, "Undefined local file path"
    end
    if remote_file_path.to_s.empty?
      remote_file_path = File.basename(local_file_path)
    end
    content = IO.binread(local_file_path)

    puts ("Uploading #{File.basename(local_file_path)} to #{remote_file_path}")
    response = @storage_api.put_create(AsposeStorageCloud::PutCreateRequest.new(remote_file_path, IO.binread(local_file_path)))
    response.status == 'OK'
  end

  ##
  # @summary Checks if file exists on storage
  # @param [string]    path   Remote file path
  #
  def is_exist(path)
    response = @storage_api.get_is_exist(AsposeStorageCloud::GetIsExistRequest.new(path))
    response.status == 'OK' && response.file_exist.is_exist
  end

  ##
  # @summary Checks if folder exists on storage
  # @param [string]    path   Remote folder path
  #
  def is_folder_exist(path)
    response = @storage_api.get_is_exist(AsposeStorageCloud::GetIsExistRequest.new(path))
    response.status == 'OK' && response.file_exist.is_exist && response.file_exist.is_folder
  end

  ##
  # @summary Downloads file from storage
  # @param [string]    file_path   Remote file path
  #
  # Temporary file path: result.to_path, file size result.length
  # Content: content = IO.binread(result.to_path)
  #
  def download_file(file_path)
    @storage_api.get_download(AsposeStorageCloud::GetDownloadRequest.new(file_path))
  end
  ##
  # @summary Creates remote folder
  # @param [string]    folder_path   Remote folder path
  #
  def create_folder(folder_path)
    response = @storage_api.put_create_folder(AsposeStorageCloud::PutCreateFolderRequest.new(folder_path))
    response.status == 'OK'
  end

end

##
# @summary OMR Demo class
#
class Demo
  ##
  # OmrDemo constructor.
  #
  def initialize()
    ##
    # File with dictionary for configuration in JSON format
    # The config file should be looked like:
    #  {
    #     "app_key"  : "xxxxx",
    #     "app_sid"   : "xxx-xxx-xxx-xxx-xxx",
    #     "base_path" : "https://api.aspose.cloud/v1.1",
    #      "data_folder" : "Data"
    #  }
    # Provide your own app_key and app_sid, which you can receive by registering at Aspose Cloud Dashboard (https://dashboard.aspose.cloud/)
    #
    @debugging = false

    @demo_data_submodule_name = 'aspose-omr-cloud-demo-data'
    @config_file_name = 'test_config.json'
    @config = []
    @data_folder = ''
    @path_to_output = './Temp'
    @logos_folder_name = 'Logos'
    @logo_files = ['logo1.jpg', 'logo2.png']
    @user_images = ['photo.jpg', 'scan.jpg']
    @template_name = 'Aspose_test'
    @template_dst_name = "#{@template_name}.txt"

    load_config

    @storage = Storage.new(@config['app_key'], @config['app_sid'], @config['base_path'], @debugging)
    @omr_api = AsposeOmrCloud::OmrApi.new(@config['app_key'], @config['app_sid'], @config['base_path'], @debugging)
  end

  ##
  #
  # @summary Retrieves full file path, located in data folder
  # @param [string]    file_name File name
  # @return string Full path to fileName
  #
  def data_file_path(file_name)
    File.join(@data_folder, file_name)
  end

  ##
  #
  # @summary Load config from local file system
  #
  def load_config
    data_folder_base = File.realpath(File.dirname(__FILE__))
    data_folder_base_old = ''
    config_file_relative_path = File.join(@demo_data_submodule_name, @config_file_name)
    config_file_path = nil
    while !File.exists?(File.join(data_folder_base, config_file_relative_path)) && data_folder_base_old != data_folder_base
      data_folder_base_old = data_folder_base
      data_folder_base = File.realpath(File.join(data_folder_base, '..'))
    end
    raise RuntimeError, "Config file not found: #{@config_file_name}" unless File.exists?(File.join(data_folder_base, config_file_relative_path))
    config_file_path = File.join(data_folder_base, config_file_relative_path)
    @config = JSON.parse(File.read(config_file_path))
    raise RuntimeError, "Config file has wrong format" unless @config.include?('app_key') && @config.include?('app_sid') && @config.include?('base_path') && @config.include?('data_folder')
    @data_folder = File.join(File.dirname(config_file_path), @config['data_folder'])
  end

  ##
  # @summary Uploads demo files to the Storage
  #
  def upload_demo_files
    @storage.create_folder(@logos_folder_name) unless @storage.is_folder_exist(@logos_folder_name)
    @logo_files.each {|file_name|
      file_path = data_file_path(file_name)
      raise RuntimeError, "Unable to upload file #{file_path}" unless @storage.upload_file(file_path,  "#{@logos_folder_name}/#{file_name}")
    }
  end

  ##
  # @summary Checks OMR Response
  # @param [AsposeOmrCloud::OMRResponse]   response   OMR Response object
  # @param [string]    text   Optional string
  # @returns [AsposeOmrCloud::OMRResponse] unchanged response object
  #
  def check_omr_response (response, text = '')
    raise RuntimeError, "Request failed #{text}" unless response.status == 'OK'
    raise RuntimeError, "OMR Request #{text} failed: #{response.error_text}" unless response.error_code == 0
    response
  end

  ##
  #
  # @summary Serialize files to JSON object
  # @param [array<string>] file_paths  array of input file paths
  # @returns [string] JSON string
  #
  def serialize_files(file_paths)
    files = []
    file_paths.each do |file_path|
      files << { :Name => File.basename(file_path),
                 :Size => File.size(file_path),
                 :Data => Base64.encode64(IO.binread(file_path))
      }
    end
    JSON({:Files => files})
  end

  ##
  # @summary Deserialize file encoded in fileInfo to folder dst_path
  # @param [AsposeOmrCloud::FileInfo]  file_info   File information object
  # @param [string] dst_path Destination path
  # @return [string] file paths on local file system
  #
  def deserialize_file(file_info, dst_path)
    FileUtils.mkdir_p(dst_path) unless File.exist?(dst_path)
    dst_file_name = File.join(dst_path, file_info.name)
    File.open(dst_file_name, 'wb') { |file|
      file.write(Base64.decode64(file_info.data))
    }
    dst_file_name
  end

  ##
  # @summary Deserialize files encoded in files to folder dst_path
  # @param [array<AsposeOmrCloud::FileInfo>]  files   Files array of FileInfo objects
  # @param [string] dst_path Destination path
  # @return [array<string>] Array of file paths on local file system
  #
  def deserialize_files(files, dst_path)
    result = []
    files.each do |file_info|
      result << deserialize_file(file_info, dst_path)
    end
    result
  end

  ##
  # @summary Generates template
  # @param [string]    $template_file_path   Template file path on local file system
  # @return [AsposeOmrCloud::OMRResponse] Generate Template Response
  #
  def generate_template(template_file_path)
    raise RuntimeError, "Unable to upload file #{template_file_path}"  unless @storage.upload_file(template_file_path)

    template_name = File.basename(template_file_path)
    response = @omr_api.post_run_omr_task(template_name, 'GenerateTemplate',
      {:param => AsposeOmrCloud::OMRFunctionParam.new({:FunctionParam => JSON({:ExtraStoragePath => @logos_folder_name})}) }
    )
    check_omr_response(response, 'GenerateTemplate')
  end

  ##
  #
  # @summary Corrects template
  # @param [string]    template_file_path   Template file path on local file system
  # @param [string]    image_file_path  Image file path on local file system
  # @return [AsposeOmrCloud::OMRResponse] Correct Template Response
  #
  def correct_template(template_file_path, image_file_path)
    raise RuntimeError, "Unable to upload file #{image_file_path}"  unless @storage.upload_file(image_file_path)

    image_name = File.basename(image_file_path)
    response = @omr_api.post_run_omr_task(image_name, 'CorrectTemplate',
                                          {:param => AsposeOmrCloud::OMRFunctionParam.new({:FunctionParam => serialize_files([template_file_path])}) }
    )
    check_omr_response(response, 'CorrectTemplate')
  end

  ##
  #
  # @summary Corrects template
  # @param [string]    template_id   Template Identifier
  # @param [string]    corrected_template_file_path  Corrected template file path on local file system
  # @return [AsposeOmrCloud::OMRResponse] Finalize Template Response
  #
  def finalize_template(template_id, corrected_template_file_path)
    raise RuntimeError, "Unable to upload file #{corrected_template_file_path}"  unless @storage.upload_file(corrected_template_file_path)

    corrected_template_file_name = File.basename(corrected_template_file_path)
    response = @omr_api.post_run_omr_task(corrected_template_file_name, 'FinalizeTemplate',
                                          {:param => AsposeOmrCloud::OMRFunctionParam.new({:FunctionParam => template_id}) }
    )
    check_omr_response(response, 'FinalizeTemplate')
  end

  ##
  #
  # @summary Recognizes image
  # @param [string]    template_id   Template Identifier
  # @param [string]    image_path  Image file path on local file system
  # @return [AsposeOmrCloud::OMRResponse] Recognize Template Response
  #
  def recognize_image(template_id, image_path)
    raise RuntimeError, "Unable to upload file #{image_path}"  unless @storage.upload_file(image_path)

    image_name = File.basename(image_path)
    response = @omr_api.post_run_omr_task(image_name, 'RecognizeImage',
                                          {:param => AsposeOmrCloud::OMRFunctionParam.new({:FunctionParam => template_id}) }
    )
    check_omr_response(response, 'RecognizeImage')
  end

  ##
  #
  # @summary Validates image (Correct and Finalize)
  # @param [string]    template_file_path   Template file path
  # @param [string]    image_file_path  Image file path on local file system
  # @return [AsposeOmrCloud::OMRResponse] Finalize Template Response
  #
  def validate_template(template_file_path, image_file_path)
    puts "\nCorrect Template ..."
    correct_template_response = correct_template(template_file_path, image_file_path)
    corrected_template_file_path = nil
    deserialize_files(correct_template_response.payload.result.response_files, @path_to_output).each do |file_path|
      file_extension = File.extname(file_path).strip.downcase[1..-1]
      corrected_template_file_path = file_path if file_extension == 'omrcr'
    end

    puts "\nFinalize Template ..."
    finalize_template(correct_template_response.payload.result.template_id, corrected_template_file_path)
  end

  def demo
    puts "Using #{@config['base_path']} as #{@config['app_sid']}"
    puts "\nUpload Demo Files  ..."
    upload_demo_files

    puts "\nGenerate Template  ..."
    generate_template_response = generate_template (data_file_path(@template_dst_name))

    template_file_path = ''
    image_file_path = ''
    deserialize_files(generate_template_response.payload.result.response_files, @path_to_output).each do |file_path|
      file_extension = File.extname(file_path).strip.downcase[1..-1]
      template_file_path = file_path if file_extension == 'omr'
      image_file_path = file_path if file_extension == 'png'
    end

    finalize_template_response = validate_template(template_file_path, image_file_path)
    template_id = finalize_template_response.payload.result.template_id

    puts "\nRecognize Images  ..."
    output_files = []
    @user_images.each do |user_image_file_name|
      recognize_image_response = recognize_image(template_id, data_file_path(user_image_file_name))
      deserialize_files(recognize_image_response.payload.result.response_files, @path_to_output).each do |file_path|
        file_extension = File.extname(file_path).strip.downcase[1..-1]
        output_files << file_path if file_extension == 'dat'
      end
    end
    print("\n------ R E S U L T ------\n")
    output_files.each do |file_path|
      puts "Output file #{file_path}"
    end
  end
end
puts "Starting OMR Demo"
demo = Demo.new
demo.demo
