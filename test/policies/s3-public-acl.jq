.resource_changes[] | 
select(.type == "aws_s3_bucket") | 
select(.change.after.acl | 
test("public-read|public-read-write")) |
{address, acl: .change.after.acl}
