require 'dnsruby'

class DnsCheckController < ApplicationController
  def check
    domain = params[:domain]

    if domain.present?
      dns_resolver = Dnsruby::Resolver.new

      @a_records = dns_resolver.query(domain, 'A').answer.select { |record| record.type == 'A' }.map(&:address).map(&:to_s)
      @ns_records = dns_resolver.query(domain, 'NS').answer.select { |record| record.type == 'NS' }.map(&:domainname).map(&:to_s)
      @mx_records = dns_resolver.query(domain, 'MX').answer.select { |record| record.type == 'MX' }.map { |record| { priority: record.preference, exchange: record.exchange.to_s } }
      @txt_records = dns_resolver.query(domain, 'TXT').answer.select { |record| record.type == 'TXT' }.map(&:strings).map { |strings| strings.join(" ") }

      # Recherchez les enregistrements CNAME pour les sous-domaines courants
      common_subdomains = ['www', 'mail', 'ftp']
      @cname_records = common_subdomains.map do |subdomain|
        begin
          cname_record = dns_resolver.query("#{subdomain}.#{domain}", 'CNAME').answer.select { |record| record.type == 'CNAME' }.map(&:domainname).map(&:to_s)
          Rails.logger.debug "CNAME record for #{subdomain}.#{domain}: #{cname_record}"
          { subdomain: subdomain, cname: cname_record.first } if cname_record.present?
        rescue Dnsruby::NXDomain
          nil
        end
      end.compact

      render json: {
        a_records: @a_records,
        ns_records: @ns_records,
        cname_records: @cname_records,
        mx_records: @mx_records,
        txt_records: @txt_records
      }
    else
      @dns_records = []
      render :home
    end
  end
end
