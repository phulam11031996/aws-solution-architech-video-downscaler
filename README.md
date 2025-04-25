<h1 align="center">
  <b>AWS Solution Architect Video Downscaler</b>
</h1>

<h2>📌 Overview</h2>
<p>The application processes and downscales videos uploaded to an S3 bucket, ensuring efficient storage and seamless delivery for end users. This project showcases my expertise in designing a <b>highly available (HA)</b>, <b>fault-tolerant (FT)</b>, and <b>disaster-resilient (DR)</b> solution using <b>AWS services</b>.

<h2>🚀 Key Features</h2>
<ul>
  <li><b>CI/CD Pipeline:</b> Implemented GitHub Actions for automated testing and deployment.</li>
  <li><b>Infrastructure as Code (IaC):</b> Used Terraform to provision and manage AWS resources.</li>
  <li><b>Scalable Architecture:</b> Utilized AWS Auto Scaling Groups (ASG) to dynamically manage EC2 instances based on workload.</li>
  <li><b>Serverless Integration:</b> Used <b>AWS SNS</b> and <b>AWS SQS</b> for a <b>pub/sub pattern</b> to decouple services and enable asynchronous communication.</li>
  <li><b>Application Load Balancer (ALB):</b> Configured ALB to distribute traffic across EC2 instances.</li>
  <li><b>Containerization:</b> Dockerized the video processing application for portability and consistency.</li>
</ul>

<h2>🛠️ Technologies Used</h2>
<h3>Infrastructure as Code</h3>
<ul>
  <li><b>🛠️ Terraform</b> – For provisioning and managing AWS resources</li>
</ul>
<h3>Containerization</h3>
<ul>
  <li>🐳 <b>Docker</b> – For packaging the video processing app into portable containers</li>
</ul>
<h3>CI/CD</h3>
<ul>
  <li>⚙️ <b>GitHub Actions</b> – For automating testing and deployment pipelines</li>
</ul>
<h3>Frontend</h3>
<ul>
  <li>⚛️ <b>React</b> – UI library for building interactive user interfaces</li>
  <li>🎨 <b>Shadcn UI</b> – Component library built on Radix UI</li>
  <li>💨 <b>Tailwind CSS</b> – Utility-first CSS framework</li>
</ul>
<h3>Backend</h3>
<ul>
  <li>🟩 <b>Node.js</b> – JavaScript runtime for server-side applications</li>
  <li>🚂 <b>Express</b> – Minimalist web framework for Node.js</li>
  <li>🐍 <b>Python</b> – Used for the video processing application</li>
</ul>
<h3>Programming & Scripting</h3>
<ul>
  <li>🐍 <b>Python</b> – Main language for video downscaling logic</li>
  <li>🖥️ <b>Bash</b> – For server setup and automation tasks</li>
</ul>

<h2>🗺️ Architecture Diagram</h2>
<div align="center">
  <img src="https://github.com/user-attachments/assets/54d0d2c1-47bb-42b4-b957-0b73b009e953" width="90%" />
</div>

<h2>⚙️ How It Works</h2>
<div align="center">
  <img src="https://github.com/user-attachments/assets/dc1badc5-220e-492c-84f9-7b3fa2119065" width="90%" />
</div>
<ol>
  <li><strong>Web App Request:</strong> The Web App requests to upload a video.</li>
  <li><strong>Generate Pre-signed URLs:</strong> The Web Server returns pre-signed PUT and GET URLs for the original and downscaled videos.</li>
  <li><strong>Upload Original Video:</strong> The Web App uploads the original video to S3 using the pre-signed PUT URL and starts polling for downscaled outputs.</li>
  <li><strong>Publish to SNS:</strong> The Web Server publishes a message to an SNS topic with video info and URLs.</li>
  <li><strong>Distribute via SQS:</strong> The SNS topic fan-outs the message to three SQS queues (for downscale x1, x2, x3).</li>
  <li><strong>Web Worker Processing:</strong> Each Web Worker polls its SQS queue, downloads the original video from S3, processes it, and uploads the downscaled result using its pre-signed URL.<br>
    – Each worker runs in an Auto Scaling Group that scales independently based on queue size.</li>
  <li><strong>Polling for Results:</strong> The Web App continues polling S3 until all downscaled videos are available.</li>
  <li><strong>S3 Lifecycle Management:</strong> A lifecycle policy automatically moves older videos into S3 Deep Archive storage to reduce storage costs.</li>
</ol>

<h2>▶️ How to Run the Project</h2>
## Prerequisites

- **Terraform**: Ensure Terraform is installed on your system. You can download it from the [Terraform official website](https://www.terraform.io/downloads).
- **Private Key File**: You will need a private key file (`key.pem`) to access EC2 instances.

---

## Steps to Run the Project

### 1. Clone the Repository

```bash
git clone https://github.com/phulam11031996/aws-solution-architech-video-downscaler.git
cd aws-solution-architech-video-downscaler
```
### 2. Generate and Place the Key File

Use AWS Management Console or AWS CLI to generate `key.pem` and copy your private key file into the `terraform/` directory and ensure it is named `key.pem`.

```bash
cp /path/to/your-key.pem terraform/key.pem
```
### 3. Initialize Terraform

Navigate to the repo `root` directory and run:

```bash
make tf-init
make tf-apply
```
### 4. Access the Application

Once the deployment is complete:

1. Retrieve the public DNS of the Application Load Balancer (ALB) from the Terraform output.
2. Open the web application in your browser using the ALB DNS.

<h2>🔮 Future Improvements</h2>
<h3>Speed Improvements</h3>
<ul>
  <li><strong>Multipart Upload:</strong> Implement multipart upload to S3 for faster and more efficient video uploads and downloads.</li>
  <li><strong>GPU-Optimized EC2 Instances:</strong> Use GPU-based EC2 instances to accelerate video processing tasks.</li>
  <li><strong>FFmpeg Optimization:</strong> Fine-tune FFmpeg settings to improve downscaling speed while maintaining quality.</li>
</ul>

<h3>Reason for Not Implementing</h3>
<p>
  These enhancements were skipped to keep the project focused on demonstrating scalable and cost-effective cloud architecture; Doing these speed improvements will incurring additional costs.
</p>

<h2>🐞 Challenges and Solutions</h2>
<h3>Challenge 1: Passing Environment Variables</h3>
<p><strong>Issue:</strong> Passing environment variables from the EC2 instance to the application running inside a Docker container was complex and required careful configuration.</p>

<h3>Challenge 2: Least Privilege Communication Between Web Tiers</h3>
<p><strong>Issue:</strong> Enforcing least privilege between web tiers required careful IAM, security group, and policy configuration. So, a lot of timeouts and 400s errors while calling the ALB.</p>

<p><strong>Solution:</strong> Used AWS Systems Manager Session Manager for secure, auditable instance access. Bash scripts were used for debugging and troubleshooting.</p>
