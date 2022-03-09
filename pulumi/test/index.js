"use strict";
const pulumi = require("@pulumi/pulumi");
const k8s = require("@pulumi/kubernetes");

let config = new pulumi.Config();
let image = config.require("image");

const appLabels = { app: "pulumi-helloworld" };
const deployment = new k8s.apps.v1.Deployment("pulumi-helloworld", {
    spec: {
        selector: { matchLabels: appLabels },
        replicas: 1,
        template: {
            metadata: { labels: appLabels },
            spec: { containers: [{ name: "pulumi-helloworld", image: image }] }
        }
    }
});
exports.name = deployment.metadata.name;
