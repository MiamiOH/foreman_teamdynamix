module ServiceHelper
  private

  def custom_attr_fields(host, custom_attrs)
    validated_fields = []
    custom_attrs.each do |attr_name, fields|
      fields = downcase_keys(fields)
      value = fields['value'].to_s
      fields['value'] = filter_vulnerabilities(host, attr_name, value)
      validated_fields << fields
    end
    validated_fields
  end

  def downcase_keys(raw_hash)
    hash_with_downcase_key = {}
    raw_hash.each_pair { |k, v| hash_with_downcase_key[k.downcase] = v }
    hash_with_downcase_key
  end

  # rubocop:disable Security/Eval, Style/StringLiterals, Lint/UnusedMethodArgument
  def filter_vulnerabilities(host, attr_name, value)
    return value unless value.include?('#{')
    error_message = "custom attribute '#{attr_name}' configuration contains insecure interpolation"
    raise error_message unless contains_secure_host_attr?(value)
    eval("\"" + value + "\"")
  rescue StandardError => e
    raise e.message
  end
  # rubocop:enable Security/Eval, Style/StringLiterals, Lint/UnusedMethodArgument

  def contains_secure_host_attr?(value)
    expression = value.split('#{')[1].split('}').first.strip
    return false unless expression.include?('host.')
    host_attr = expression.split('host.').last
    permissible_host_attrs.include?(host_attr)
  end

  def permissible_host_attrs
    @host.attributes.keys
  end

  def must_configure_create_params
    [:StatusID]
  end

  def valid_auth_token?(token)
    token.match(/^[a-zA-Z0-9\.\-\_]*$/)
  end
end
