require 'dnsruby'

class DnsLookupsController < ApplicationController
    def lookup
        if params[:domain].present?
            domain = params[:domain]

            # Ajouter un préfixe "www." si le domaine ne commence pas déjà par "www."
            domain = "www.#{domain}" unless domain.start_with?('www.')

            resolver = Dnsruby::Resolver.new

            record_types = [Dnsruby::Types.A, Dnsruby::Types.AAAA, Dnsruby::Types.CNAME, Dnsruby::Types.NS, Dnsruby::Types.MX, Dnsruby::Types.TXT]
            @results = {}

            record_types.each do |record_type|
            begin
                @results[record_type] = resolver.query(domain, record_type).answer
            rescue Dnsruby::NXDomain, Dnsruby::ResolvTimeout
                @results[record_type] = nil
            end
            end
        end
    end
end
