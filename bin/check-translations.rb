#!/usr/bin/env ruby
#
#  check-translations.rb DIR LANG
#

require 'yaml'

dir  = ARGV[0]
lang = ARGV[1]

i18n_en   = YAML.load_file("#{dir}/en.yml")
i18n_lang = YAML.load_file("#{dir}/#{lang}.yml")

def look_for_error(path, data)
    if data.nil?
        puts "No data for #{path.sub(/^\./, '')}"
        return true
    elsif data.class == Hash
        data.keys.sort.each do |key|
            if look_for_error(path + '.' + key, data[key])
                return true
            end
        end
    end
    return false
end

def walk(path, en, other)
    en.keys.sort.each do |key|
        name = path.sub(/^\./, '') + '.' + key
        if en[key].class == Hash
            if other.nil?
                puts "MISSING: #{name} [en=#{en[key]}]"
            else
                walk(path + '.' + key, en[key], other[key])
                if other[key] && other[key].empty?
                    other.delete(key)
                end
            end
        else
#            puts "#{name} [#{en[key]}] [#{other[key]}]"
            if other.nil? || ! other[key]
                puts "MISSING: #{name} [en=#{en[key]}]"
            else
                other.delete(key)
            end
        end
    end
end


if look_for_error('', i18n_lang)
    exit 1
end

walk('', i18n_en, i18n_lang)


unless i18n_lang.empty?
    puts "keys in translation that are not in English version:"
    require 'pp'
    pp i18n_lang
end

