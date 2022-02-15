db = connect( 'agora' );

print('Database: ' + db.getName());
print('Host: ' + db.serverStatus().host);
printjson(db.teaminfo.getIndexes());

db.teaminfo.createIndex({
    'program'   : 1,
    'team_full' : 1
});

var teamInfoIndexes = db.teaminfo.getIndexes();
var teamInfoSortIndex;

if (teamInfoIndexes) {
    for (let index of teamInfoIndexes) {
        if ('program_1_team_full_1' == index.name) {
            teamInfoSortIndex = index;
            break;
        }
    }
}

if (teamInfoSortIndex) {
    print('Index added for teaminfo:');
    printjson(teamInfoSortIndex);
}
else {
    print('Index creation failed for teaminfo...');
}