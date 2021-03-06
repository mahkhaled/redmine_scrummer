module ScrumChartsHelper
  def scrummer_image_path path
    '../plugin_assets/redmine_scrummer/images/' + path
  end

  # returns hash values sorted with the same order of sorted keys
  # TODO move this function to Hash class or file an alternative way to do this
  def values_sorted_by_keys(hash)
    hash ||= {}
  	hash.keys.sort.map{|k| hash[k]}.inspect.html_safe
  end

  # helper changes a hash of this form {:legend => [data array], ...}
  # to array of for [{name => hash, data => [data array]}, ...]
  # TODO: i think we can add this fuction to hash class
  def map_to_charts_series(hash)
  	hash ||= {}
    keys = hash.keys
  	ar = []
  	keys.each do |k|
  		h = {}
  		h['name'] = k
  		h['data'] = hash[k]

      h['data'].each do |i|
        i[0] = i.first.to_s
      end

  		ar << h
  	end
  	ar.to_json.html_safe
  end
end
