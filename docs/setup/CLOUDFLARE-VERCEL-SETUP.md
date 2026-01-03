# Setting Up staging.freshwall.app with Cloudflare + Vercel

Quick guide for configuring your staging subdomain when using Cloudflare as your DNS provider.

## Step 1: Add DNS Record in Cloudflare

### Via Cloudflare Dashboard:

1. Log in to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Select your domain: `freshwall.app`
3. Go to **DNS** → **Records**
4. Click **Add record**
5. Configure:
   ```
   Type:    CNAME
   Name:    staging
   Target:  cname.vercel-dns.com
   Proxy:   🟠 DNS only (click the cloud to disable proxy)
   TTL:     Auto
   ```

**IMPORTANT**: Make sure the proxy status is **DNS only** (gray cloud ☁️), not **Proxied** (orange cloud 🟠).

### Why DNS Only?

Vercel needs to handle the SSL certificate. If Cloudflare proxies the traffic:
- Vercel can't verify domain ownership
- SSL certificate provisioning fails
- Staging subdomain won't work

You can enable Cloudflare proxy **after** Vercel successfully provisions the SSL certificate.

### Via Cloudflare API (Alternative):

```bash
curl -X POST "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/dns_records" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "CNAME",
    "name": "staging",
    "content": "cname.vercel-dns.com",
    "ttl": 1,
    "proxied": false
  }'
```

## Step 2: Add Domain in Vercel

1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Select your FreshWall Web project
3. Go to **Settings** → **Domains**
4. Click **Add**
5. Enter: `staging.freshwall.app`
6. Click **Add**

Vercel will now:
- Detect the CNAME record
- Verify domain ownership
- Provision SSL certificate (takes 1-2 minutes)
- Show status as "Valid" when ready

## Step 3: Assign Domain to Branch

In Vercel Dashboard (same Domains page):

1. Find `staging.freshwall.app` in the list
2. Click the **Edit** button (3 dots or gear icon)
3. Click **Assign to Git Branch**
4. Select: `staging` branch
5. Click **Save** or **Assign**

Now the `staging` branch will deploy to `staging.freshwall.app`

## Step 4: Verify DNS Propagation

```bash
# Check if CNAME is set correctly
dig staging.freshwall.app CNAME

# Should show:
# staging.freshwall.app. 300 IN CNAME cname.vercel-dns.com.

# Or use:
nslookup staging.freshwall.app
```

## Step 5: Test Deployment

```bash
# Create and push staging branch
git checkout -b staging
git push origin staging

# Vercel automatically deploys
# Visit: https://staging.freshwall.app
```

## Cloudflare-Specific Considerations

### SSL/TLS Settings

In Cloudflare → SSL/TLS → Overview:
- Set to **Full** or **Full (strict)**
- **Don't use** Flexible SSL (causes redirect loops)

### Page Rules (Optional)

If you want different caching for staging:

1. Cloudflare → **Rules** → **Page Rules**
2. Create rule for: `staging.freshwall.app/*`
3. Settings:
   - Cache Level: Bypass
   - Disable Performance features (optional)

This prevents Cloudflare from caching staging content aggressively.

### Enabling Cloudflare Proxy Later

After Vercel successfully provisions SSL:

1. Go back to Cloudflare DNS records
2. Find the `staging` CNAME record
3. Click the cloud icon to enable proxy (gray → orange)

**Benefits of enabling proxy:**
- DDoS protection
- Additional caching
- Web Application Firewall (WAF)
- Analytics

**Downsides:**
- Slight latency increase
- Cloudflare becomes a man-in-the-middle
- Need to manage SSL at both Cloudflare and Vercel

**Recommendation for staging**: Leave proxy **disabled** (DNS only) for staging to keep it simple and fast.

## Troubleshooting

### "Domain not verified" in Vercel

**Solution:**
1. Check DNS in Cloudflare - ensure CNAME exists
2. Ensure proxy is **disabled** (gray cloud)
3. Wait 5-10 minutes for DNS propagation
4. Click "Refresh" in Vercel

### "Too many redirects" error

**Solution:**
1. Go to Cloudflare → SSL/TLS
2. Change from "Flexible" to "Full" or "Full (strict)"
3. Wait a few minutes
4. Clear browser cache and try again

### SSL certificate not provisioning

**Solution:**
1. Verify CNAME record is correct: `cname.vercel-dns.com`
2. Disable Cloudflare proxy (orange → gray cloud)
3. Wait for Vercel to provision certificate
4. Can re-enable proxy after certificate is issued

### DNS propagation taking too long

**Solution:**
```bash
# Check propagation globally
# Visit: https://www.whatsmydns.net/#CNAME/staging.freshwall.app

# Force DNS refresh (macOS)
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# Force DNS refresh (Windows)
ipconfig /flushdns
```

## Quick Setup Checklist

- [ ] Add CNAME record in Cloudflare (DNS only mode)
- [ ] Add domain `staging.freshwall.app` in Vercel
- [ ] Wait for SSL certificate provisioning
- [ ] Assign domain to `staging` branch
- [ ] Create and push `staging` branch
- [ ] Verify deployment at `staging.freshwall.app`
- [ ] Configure environment variables in Vercel (Preview scope)
- [ ] Test with staging Firebase backend

## Recommended Cloudflare Settings for Staging

### DNS:
```
staging    CNAME    cname.vercel-dns.com    DNS only (gray cloud)
```

### SSL/TLS:
- Mode: Full (strict)
- Edge Certificates: Automatic
- Minimum TLS: 1.2

### Speed:
- Auto Minify: Disabled (let Vercel handle it)
- Brotli: Enabled

### Caching:
- Caching Level: Standard
- Browser Cache TTL: Respect Existing Headers

### Network:
- HTTP/2: Enabled
- HTTP/3 (with QUIC): Enabled

## Production vs Staging DNS

Your final DNS setup in Cloudflare:

```
# Production (can enable proxy)
freshwall.app       CNAME    cname.vercel-dns.com    🟠 Proxied
www.freshwall.app   CNAME    cname.vercel-dns.com    🟠 Proxied

# Staging (recommend DNS only)
staging.freshwall.app    CNAME    cname.vercel-dns.com    ☁️ DNS only
```

## Alternative: Cloudflare Pages vs Vercel

If you wanted to stay fully in Cloudflare ecosystem, you could use:
- **Cloudflare Pages** instead of Vercel
- Same features: automatic deployments, preview URLs, edge functions
- Tighter Cloudflare integration

**But since you're already on Vercel**, stick with it. Vercel + Cloudflare DNS works great together.

---

**Last Updated**: January 2025
**Verified with**: Cloudflare + Vercel
