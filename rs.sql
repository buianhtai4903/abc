backup database [AdventureWorks2008R2]
to disk = '.bak'
with init;

backup database [AdventureWorks2008R2]
to disk = 'diff.bak'
with differential;

backup log [AdventureWorks2008R2]
to disk = 'log.bak';

drop database [AdventureWorks2008R2];

restore database [AdventureWorks2008R2]
from disk = '.bak'
with norecovery;

restore database [AdventureWorks2008R2]
from disk = 'diff.bak'
with norecovery;

restore log [AdventureWorks2008R2]
from disk = 'log.bak'
with norecovery;

restore database [AdventureWorks2008R2]
with recovery;