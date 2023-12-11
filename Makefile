define sops_encrypt
	@if [ -e $(2) ]; then \
		sops -e -a $(file <./sops-age-key.pub) --input-type=$(1) --output-type=$(1) $(2) > $(2).enc; \
		echo "+ Encrypted file $(2)"; \
	else \
		echo "- File $(2) not found"; \
	fi
endef

define sops_decrypt
	@if [ -e $(2).enc ]; then \
	sops -d --input-type=$(1) --output-type=$(1) $(2).enc > $(2); \
		echo "+ Decrypted file $(2)"; \
	else \
		echo "- File $(2).enc not found"; \
	fi
endef

define remove_file
	@if [ -e $(1) ]; then \
	rm $(1); \
		echo "+ Removed file $(1)"; \
	else \
		echo "- File $(1) not found"; \
	fi
endef

define run_playbook
	ansible-playbook playbooks/$(1).yml -i inventory/$(2) -bK $(3)
endef

encrypt:
	$(call sops_encrypt,yaml,inventory/dus01-sip)
	$(call sops_encrypt,yaml,inventory/dus02-prox)
	$(call sops_encrypt,dotenv,roles/cloudproxy/files/cloudproxy.env)
	$(call sops_encrypt,binary,roles/cloudproxy/files/wireguard/wg_confs/wg0.conf)
	$(call sops_encrypt,binary,roles/cloudproxy/files/wireguard/server/privatekey-server)
	$(call sops_encrypt,binary,roles/cloudproxy/files/wireguard/server/publickey-server)
	$(call sops_encrypt,dotenv,roles/onsiteproxy/files/onsiteproxy.env)
	$(call sops_encrypt,binary,roles/onsiteproxy/files/wireguard/wg_confs/wg0.conf)
	$(call sops_encrypt,binary,roles/onsiteproxy/files/wireguard/server/privatekey-server)
	$(call sops_encrypt,binary,roles/onsiteproxy/files/wireguard/server/publickey-server)

decrypt:
	$(call sops_decrypt,yaml,inventory/dus01-sip)
	$(call sops_decrypt,yaml,inventory/dus02-prox)
	$(call sops_decrypt,dotenv,roles/cloudproxy/files/cloudproxy.env)
	$(call sops_decrypt,binary,roles/cloudproxy/files/wireguard/wg_confs/wg0.conf)
	$(call sops_decrypt,binary,roles/cloudproxy/files/wireguard/server/privatekey-server)
	$(call sops_decrypt,binary,roles/cloudproxy/files/wireguard/server/publickey-server)
	$(call sops_decrypt,dotenv,roles/onsiteproxy/files/onsiteproxy.env)
	$(call sops_decrypt,binary,roles/onsiteproxy/files/wireguard/wg_confs/wg0.conf)
	$(call sops_decrypt,binary,roles/onsiteproxy/files/wireguard/server/privatekey-server)
	$(call sops_decrypt,binary,roles/onsiteproxy/files/wireguard/server/publickey-server)

clean:
	$(call remove_file,inventory/dus01-sip)
	$(call remove_file,inventory/dus02-prox)
	$(call remove_file,roles/cloudproxy/files/cloudproxy.env)
	$(call remove_file,roles/cloudproxy/files/wireguard/wg_confs/wg0.conf)
	$(call remove_file,roles/cloudproxy/files/wireguard/server/privatekey-server)
	$(call remove_file,roles/cloudproxy/files/wireguard/server/publickey-server)
	$(call remove_file,roles/onsiteproxy/files/onsiteproxy.env)
	$(call remove_file,roles/onsiteproxy/files/wireguard/wg_confs/wg0.conf)
	$(call remove_file,roles/onsiteproxy/files/wireguard/server/privatekey-server)
	$(call remove_file,roles/onsiteproxy/files/wireguard/server/publickey-server)

cloudproxy-sip:
	$(call sops_decrypt,yaml,inventory/dus01-sip)
	$(call run_playbook,cloudproxy,dus01-sip)

onsiteproxy-prox:
	$(call run_playbook,onsiteproxy,dus02-prox)
