pipeline {
    agent { dockerfile true }
    options {
        disableConcurrentBuilds()
    }
    triggers {
        pollSCM('H/5 * * * *')
    }
    stages {
        stage('Clean') {
            steps {
                // https://jenkins.io/doc/pipeline/steps/ws-cleanup/
                cleanWs notFailBuild: true, patterns: [
                    [pattern: 'dist/**/*', type: 'INCLUDE'],
                    [pattern: '*.zip', type: 'INCLUDE'],
                    [pattern: '*.zip.md5', type: 'INCLUDE'],
                    [pattern: '*.spec', type: 'INCLUDE']
                ]
            }
        }
        stage('Build') {
            steps {
                sh 'find src -maxdepth 1 -type f | xargs -L 1 bash compile_sh.sh'
                sh 'cd dist && md5sum * > checksum.md5'
                sh 'echo "$BUILD_ID" > dist/VERSION'
            }
        }
        stage('ZipArtifacts') {
            steps {
                // https://jenkins.io/doc/pipeline/steps/pipeline-utility-steps/
                zip zipFile: "docker-utils-${env.BUILD_ID}.zip", archive: false, dir: 'dist'
                sh 'md5sum "docker-utils-${BUILD_ID}.zip" > docker-utils-${BUILD_ID}.zip.md5'
                archiveArtifacts artifacts: "docker-utils-${env.BUILD_ID}.zip,docker-utils-${env.BUILD_ID}.zip.md5", fingerprint: true, onlyIfSuccessful: true
            }
        }
        stage('Deploy') {
            steps {
                sshPublisher(
                    publishers: [
                        sshPublisherDesc(
                            configName: 'srv.loopback.it:/srv/docker',
                            transfers: [
                                sshTransfer(
                                    execCommand: "mkdir -p /srv/docker/repository/data/docker-utils"
                                ),
                                sshTransfer(
                                    remoteDirectory: 'repository/data/docker-utils',
                                    sourceFiles: "docker-utils-${env.BUILD_ID}.zip,docker-utils-${env.BUILD_ID}.zip.md5,dist/VERSION",
                                ),
                                sshTransfer(
                                    remoteDirectory: 'repository/data/docker-utils',
                                    removePrefix: 'dist',
                                    sourceFiles: "dist/VERSION,dist/download-commands.sh",
                                ),
                                sshTransfer(
                                    //execCommand: "cp --remove-destination /srv/docker/repository/data/docker-utils-${env.BUILD_ID}.zip /srv/docker/repository/data/docker-utils.zip"
                                    execCommand: "ln -sfr /srv/docker/repository/data/docker-utils/docker-utils-${env.BUILD_ID}.zip /srv/docker/repository/data/docker-utils/docker-utils.zip"
                                ),
                                sshTransfer(
                                    execCommand: "ln -sfr /srv/docker/repository/data/docker-utils/docker-utils-${env.BUILD_ID}.zip.md5 /srv/docker/repository/data/docker-utils/docker-utils.zip.md5"
                                ),
                                sshTransfer(
                                    execCommand: "cd /srv/docker/repository/data/docker-utils ; md5sum -c docker-utils-${env.BUILD_ID}.zip.md5"
                                ),
                            ],
                            verbose: true
                        )
                    ]
                )
            }
        }
    }
}
