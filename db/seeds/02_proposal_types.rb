location = Location.find_or_create_by!(name: 'BIRS', country: 'Canada', code: 'CA', city: 'Banff')

location.proposal_types.find_or_create_by!(name: '5 Day Workshop')
location.proposal_types.find_or_create_by!(name: '2 Day Workshop')
location.proposal_types.find_or_create_by!(name: 'Research In Teams')
location.proposal_types.find_or_create_by!(name: 'Focussed Research Group')
location.proposal_types.find_or_create_by!(name: 'Summer School')

location = Location.find_or_create_by!(name: 'New york')

location.proposal_types.find_or_create_by!(name: '5 Day Workshop')
location.proposal_types.find_or_create_by!(name: 'Summer School')
