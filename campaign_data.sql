use codechallengetable;
delimiter //
create procedure campaign_data () 
begin 
select campaign.id,
	campaign.cpm, 
	campaign.name, 
	sum(creative.clicks) as clicks, 
	sum(creative.views) as views 
from creative 
inner join campaign on campaign.id = creative.parentId 
	group by campaign.id, campaign.name, campaign.cpm order by campaign.name; 
end;
//
