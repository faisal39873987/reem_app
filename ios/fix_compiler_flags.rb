# This is a custom script to fix the -G compiler flag issue
require 'xcodeproj'

def remove_g_flag(config)
  return unless config.build_settings['OTHER_LDFLAGS']
  
  current_flags = config.build_settings['OTHER_LDFLAGS']
  if current_flags.is_a?(String)
    config.build_settings['OTHER_LDFLAGS'] = current_flags.gsub(/-G\b/, '').gsub(/-force_load\b/, '').gsub(/-ObjC\b/, '')
  elsif current_flags.is_a?(Array)
    config.build_settings['OTHER_LDFLAGS'] = current_flags.reject { |flag| ['-G', '-force_load', '-ObjC'].include?(flag) }
  end
  
  # Additional Xcode 15 settings
  config.build_settings['ENABLE_BITCODE'] = 'NO'
  config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
  config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
  config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
end

def process_project(project_path)
  project = Xcodeproj::Project.open(project_path)
  project.targets.each do |target|
    target.build_configurations.each do |config|
      remove_g_flag(config)
    end
  end
  project.save
end
