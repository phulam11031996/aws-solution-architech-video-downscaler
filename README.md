<h1 style="text-align: center; font-weight: bold; margin: 0 auto; font-size: 50px;">
  AWS Solution Architect Video Downscaler
</h1>

<h2 style="text-align: center; font-weight: bold; font-size: 40px;">📌 Overview</h2>
<p>This application allows users to upload a video, and in return, the web app provides three downscaled versions of the video for the user to download. This project showcases my expertise in designing a <b>highly available (HA)</b>, <b>fault-tolerant (FT)</b>, and <b>disaster-resilient (DR)</b> solution using <b>AWS services</b>.</p>

<h2 style="text-align: center; font-weight: bold; font-size: 40px;">🚀 Key Features</h2>
<ul>
  <li><b>Scalable Architecture:</b> Utilized AWS Auto Scaling Groups (ASG) to automatically scale EC2 instances up and down based on workload, ensuring cost efficiency and optimal performance.</li>
  <li><b>Regional Resilience:</b> Spread the web tier across multiple availability zones, ensuring high availability and fault tolerance for the application.</li>
  <li><b>Serverless Integration:</b> Used AWS SNS and AWS SQS for a pub/sub pattern to decouple services and enable asynchronous communication, enhancing scalability and flexibility.</li>
  <li><b>Application Load Balancer (ALB):</b> Configured ALB to distribute traffic evenly across EC2 instances, improving load distribution and application performance.</li>
</ul>

<h2 style="text-align: center; font-weight: bold; font-size: 40px;">🛠️ Technologies Used</h2>
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

<h2 style="text-align: center; font-weight: bold; font-size: 40px;">🗺️ Architecture Diagram</h2>
<div align="center">
  <img src="https://github.com/user-attachments/assets/54d0d2c1-47bb-42b4-b957-0b73b009e953" width="90%" />
</div>

<h2 style="text-align: center; font-weight: bold; font-size: 40px;">⚙️ How It Works</h2>
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

<h2 style="text-align: center; font-weight: bold; font-size: 40px;">▶️ How to Run the Project</h2>
<h3>Prerequisites</h3>
<ul>
  <li><strong>Terraform</strong>: Ensure Terraform is installed on your system. You can download it from the <a href="https://www.terraform.io/downloads" target="_blank">Terraform official website</a>.</li>
  <li><strong>Private Key File</strong>: You will need a private key file (<code>test-key-pair.pem</code>) to access EC2 instances.</li>
</ul>

<h3>Steps to Run the Project</h3>

<h4>1. Clone the Repository</h4>
<pre><code>git clone https://github.com/phulam11031996/aws-solution-architech-video-downscaler.git
cd aws-solution-architech-video-downscaler</code></pre>

<h4>2. Generate and Place the Key File</h4>
<p>Use AWS Management Console or AWS CLI to generate <code>test-key-pair.pem</code> and copy your private key file into the <code>terraform/</code> directory and ensure it is named <code>test-key-pair.pem</code>.</p>
<pre><code>cp /path/to/your-key.pem terraform/test-key-pair.pem</code></pre>

<h4>3. Initialize Terraform</h4>
<p>Navigate to the repo <code>root</code> directory and run:</p>
<pre><code>make tf-init
make tf-apply</code></pre>

<h4>4. Access the Application</h4>
<p>Once the deployment is complete:</p>
<ol>
  <li>Retrieve the public DNS of the Application Load Balancer (ALB) from the Terraform output.</li>
  <li>Wait 2 - 3 minutes for the useData to complete and open the web application in your browser using the ALB DNS.</li>
</ol>

<h2 style="text-align: center; font-weight: bold; font-size: 40px;">🔮 Future Improvements</h2>
<h3>Speed Improvements</h3>
<ul>
  <li><strong>Multipart Upload:</strong> Implement multipart upload to S3 for faster and more efficient video uploads and downloads.</li>
  <li><strong>GPU-Optimized EC2 Instances:</strong> Use GPU-based EC2 instances to accelerate video processing tasks.</li>
  <li><strong>FFmpeg Optimization:</strong> Fine-tune FFmpeg settings to improve downscaling speed while maintaining quality.</li>
</ul>

<h3>Reason for Not Implementing</h3>
<p>
  These enhancements were skipped to keep the project focused on demonstrating scalable and cost-effective cloud architecture; Doing these speed improvements will incur additional costs.
</p>

<h2 style="font-size: 40px;">🐞 Challenges and Solutions</h2>
<h3>Challenge 1: Passing Environment Variables</h3>
<p><strong>Issue:</strong> Passing environment variables from the EC2 instance to the application running inside a Docker container was complex and required careful configuration.</p>

<h3>Challenge 2: Least Privilege Communication Between Web Tiers</h3>
<p><strong>Issue:</strong> Enforcing least privilege between web tiers required careful IAM, security group, and policy configuration. So, a lot of timeouts and 400s errors while calling the ALB.</p>

<p><strong>Solution:</strong> Used AWS Systems Manager Session Manager for secure, auditable instance access. Bash scripts were used for debugging and troubleshooting.</p>
