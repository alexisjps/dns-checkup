Rails.application.routes.draw do
  root to: "dns_lookups#lookup"
  get 'dns_lookups/lookup', to: 'dns_lookups#lookup', as: 'dns_lookups_lookup'
end
