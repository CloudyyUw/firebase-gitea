const express = require('express'),
    app = express(),
    firebaseHostingUpload = require('./deployFileModule'),
    { exec } = require('child_process'),
    { join } = require('path');

app.get('/api/node/backup', (req, res) => {
    const { key, upload } = req.query;

    if (key !== process.env.AUTH_KEY) {
        res.sendStatus(403);
        return;
    }
    exec(`gitea dump -c /data/gitea/conf/app.ini`, (err, stdout, stderr) => {
        if (err) {
            console.error(err);
            res.json({
                err: err.message,
            });
            return;
        }
        if (stderr) console.log(stderr);

        let backupZip = join(
            process.env.TMPDIR,
            stdout.match(/gitea-dump-.*$/)[0]
        );

        if (upload == true) {
            firebaseHostingUpload(prcoess.env.SITE, [], [backupZip]).then(
                () => {
                    firebaseHostingUpload(
                        prcoess.env.SITE,
                        [],
                        [backupZip],
                        'commit'
                    );
                }
            );
            res.json({
                message: `File: ${stdout.match(/gitea-dump-.*$/)[0]}`,
            });
            return;
        } else {
            res.json({
                message: `File: ${stdout.match(/gitea-dump-.*$/)[0]}`,
            });
        }
    });
});

app.get('/api/node/download', (req, res) => {
    const { key, id } = req.query;
    if (key !== process.env.AUTH_KEY) {
        res.sendStatus(403);
        return;
    }
    res.sendFile(join(process.env.TMPDIR, `gitea-dump-${id}.zip`));
});

app.listen(process.env.NODE_PORT, () => {
    console.log('Node API online');
});
