Rails.application.routes.draw do
  root to: 'dns_check#check'
  get 'dns_check/check', to: 'dns_check#check'
end
