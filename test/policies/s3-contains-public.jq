.resource_changes[] | 
select(.type == "aws_s3_bucket") | 
select(.change.after.acl | 
contains( "public" )) |
{address, acl: .change.after.acl}
